set -xe

PREFIX=restore-test
GKE_VERSION=1.15.12-gke.6002
GKE_ZONE=us-east1-b

gcloud container clusters create $PREFIX-cluster --cluster-version=$GKE_VERSION --disk-size=100 --num-nodes=1 --machine-type=n1-standard-4 --zone $GKE_ZONE

gcloud compute disks create "$PREFIX-postgres-pd" --size 10Gi --zone us-east1-b
gcloud compute disks create "$PREFIX-nfs-pd" --size 250Gi --zone us-east1-b

time sh -c "kubectl create ns $PREFIX; helm install -n $PREFIX $PREFIX-gxy-rls ./galaxykubeman\
    --wait\
    --timeout 600s\
    --set nfs.storageClass.name=\"nfs-$PREFIX\" \
    --set cvmfs.repositories.cvmfs-gxy-data-$PREFIX=\"data.galaxyproject.org\" \
    --set cvmfs.repositories.cvmfs-gxy-main-$PREFIX=\"main.galaxyproject.org\" \
    --set cvmfs.cache.alienCache.storageClass=\"nfs-$PREFIX\" \
    --set galaxy.persistence.storageClass=\"nfs-$PREFIX\" \
    --set galaxy.cvmfs.data.pvc.storageClassName=cvmfs-gxy-data-$PREFIX \
    --set galaxy.cvmfs.main.pvc.storageClassName=cvmfs-gxy-main-$PREFIX \
    --set galaxy.service.type=LoadBalancer \
    --set rbac.enabled=false\
    --set galaxy.image.repository=\"galaxy/galaxy-anvil\" \
    --set galaxy.image.tag=20.09 \
    --set galaxy.terra.launch.workspace=\"De novo transcriptome reconstruction with RNA-Seq\"\
    --set galaxy.terra.launch.namespace=\"galaxy-anvil\"\
    --set cvmfs.cache.preload.enabled=false\
    --set galaxy.configs.\"galaxy\.yml\".galaxy.single_user=\"alex@fake.org\"\
    --set galaxy.configs.\"galaxy\.yml\".galaxy.admin_users=\"alex@fake.org\"\
    --set persistence.nfs.name=\"$PREFIX-nfs-disk\"\
    --set persistence.nfs.persistentVolume.extraSpec.gcePersistentDisk.pdName=\"$PREFIX-nfs-pd\"\
    --set persistence.nfs.size=\"250Gi\" \
    --set persistence.postgres.name=\"$PREFIX-postgres-disk\" \
    --set persistence.postgres.persistentVolume.extraSpec.gcePersistentDisk.pdName=\"$PREFIX-postgres-pd\" \
    --set persistence.postgres.size=\"10Gi\"\
    --set nfs.persistence.existingClaim=\"$PREFIX-nfs-disk-pvc\" \
    --set nfs.persistence.size=\"250Gi\" \
    --set galaxy.postgresql.persistence.existingClaim=\"$PREFIX-postgres-disk-pvc\" \
    --set galaxy.persistence.size=\"200Gi\"\
    --set galaxy.postgresql.galaxyDatabasePassword=\"averysecurepassword\""

echo "Galaxy should be up. Upload a file, here's a link:\n https://zenodo.org/record/583140/files/Megakaryocyte_rep2_reverse_read_%28SRR549358_2%29?download=1"

GALAXY_PVC_ID=$(kubectl get pvc -n $PREFIX $PREFIX-gxy-rls-galaxy-pvc -o=jsonpath='{.metadata.uid}')
CVMFS_PVC_ID=$(kubectl get pvc -n $PREFIX $PREFIX-gxy-rls-cvmfs-alien-cache-pvc -o=jsonpath='{.metadata.uid}')

gcloud container clusters create $PREFIX-cluster-2 --cluster-version=$GKE_VERSION --disk-size=100 --num-nodes=1 --machine-type=n1-standard-4 --zone $GKE_ZONE

echo "\n\nUpload a file, here's a link:\n https://zenodo.org/record/583140/files/Megakaryocyte_rep2_reverse_read_%28SRR549358_2%29?download=1\n\n"

read -p "Press Enter to delete the previous cluster and install Galaxy on the second cluster"

gcloud container clusters delete $PREFIX-cluster --zone $GKE_ZONE

time sh -c "kubectl create ns $PREFIX; helm install -n $PREFIX $PREFIX-gxy-rls ./galaxykubeman\
    --wait\
    --timeout 600s\
    --set nfs.storageClass.name=\"nfs-$PREFIX\" \
    --set cvmfs.repositories.cvmfs-gxy-data-$PREFIX=\"data.galaxyproject.org\" \
    --set cvmfs.repositories.cvmfs-gxy-main-$PREFIX=\"main.galaxyproject.org\" \
    --set cvmfs.cache.alienCache.storageClass=\"nfs-$PREFIX\" \
    --set galaxy.persistence.storageClass=\"nfs-$PREFIX\" \
    --set galaxy.cvmfs.data.pvc.storageClassName=cvmfs-gxy-data-$PREFIX \
    --set galaxy.cvmfs.main.pvc.storageClassName=cvmfs-gxy-main-$PREFIX \
    --set galaxy.service.type=LoadBalancer \
    --set rbac.enabled=false\
    --set galaxy.image.repository=\"galaxy/galaxy-anvil\" \
    --set galaxy.image.tag=20.09 \
    --set galaxy.terra.launch.workspace=\"De novo transcriptome reconstruction with RNA-Seq\"\
    --set galaxy.terra.launch.namespace=\"galaxy-anvil\"\
    --set cvmfs.cache.preload.enabled=false\
    --set galaxy.configs.\"galaxy\.yml\".galaxy.single_user=\"alex@fake.org\"\
    --set galaxy.configs.\"galaxy\.yml\".galaxy.admin_users=\"alex@fake.org\"\
    --set persistence.nfs.name=\"$PREFIX-nfs-disk\"\
    --set persistence.nfs.persistentVolume.extraSpec.gcePersistentDisk.pdName=\"$PREFIX-nfs-pd\"\
    --set persistence.nfs.size=\"250Gi\" \
    --set persistence.postgres.name=\"$PREFIX-postgres-disk\" \
    --set persistence.postgres.persistentVolume.extraSpec.gcePersistentDisk.pdName=\"$PREFIX-postgres-pd\" \
    --set persistence.postgres.size=\"10Gi\"\
    --set nfs.persistence.existingClaim=\"$PREFIX-nfs-disk-pvc\" \
    --set nfs.persistence.size=\"250Gi\" \
    --set galaxy.postgresql.persistence.existingClaim=\"$PREFIX-postgres-disk-pvc\" \
    --set galaxy.persistence.size=\"200Gi\"\
    --set galaxy.postgresql.galaxyDatabasePassword=\"averysecurepassword\"\
    --set restore.persistence.nfs.galaxy.pvcID=\"$GALAXY_PVC_ID\"\
    --set restore.persistence.nfs.cvmfsCache.pvcID=\"$CVMFS_PVC_ID\"\
    --set galaxy.persistence.existingClaim=\"$PREFIX-gxy-rls-galaxy-pvc\"\
    --set cvmfs.cache.alienCache.existingClaim=\"$PREFIX-gxy-rls-cvmfs-alien-cache-pvc\""

read -p "Galaxy should be up. Run a tool! Press enter when you're ready for the cluster to be deleted!"

gcloud container clusters delete $PREFIX-cluster-2 --zone $GKE_ZONE;

gcloud compute disks delete "$PREFIX-postgres-pd" --zone us-east1-b;
gcloud compute disks delete "$PREFIX-nfs-pd" --zone us-east1-b;


