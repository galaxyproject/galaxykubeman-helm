# Galaxy on Kubernetes Management (GalaxyKubeMan) Helm Chart
Helm chart for GalaxyKubeMan (GKM) used for deploying Galaxy on GKE/AnVIL.

## Creating a cluster and deploying Galaxy

The following command should get everything set up. Start by launching a GKE
cluster, then install a dependencies chart that deploys necessary operators,
create a persistent disk, and then install GKM, which will install Galaxy.

The `sample-values.yaml` file contains the values to deploy a test/dev version
of GKM. In addition, you will need to copy `sample-auth.yaml` to the `templates`
folder before deploying a dev instance. Also, update the values of `persistence.postgres.persistentVolume.extraSpec.csi.volumeHandle` to the correct project id.

```console
gcloud container clusters create example-gke-cluster --cluster-version="1.30" --no-enable-autorepair --disk-size=200 --num-nodes=1 --machine-type=e2-standard-16 --zone "us-east1-b --addons=GcePersistentDiskCsiDriver"

helm repo add cloudve https://raw.githubusercontent.com/CloudVE/helm-charts/master/
helm repo update
helm install --create-namespace -n "galaxy-deps" galaxy-deps cloudve/galaxy-deps --set cvmfs.cvmfscsi.nodeplugin.priorityClassName=""

gcloud compute disks create "nfs-pd" --size 300Gi --zone "us-east1-b"
gcloud compute disks create "postgres-pd" --size 10Gi --zone "us-east1-b"

git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
cp sample-auth.yaml templates/auth.yaml
helm dependency update
helm upgrade --install --create-namespace -n gkmns gkm . --values sample-values.yaml --wait --wait-for-jobs
```

It will take about 5 minutes for the Galaxy instance to be ready. It will be available at http://[galaxy-nginx service external IP]/galaxy/.

### Deploying 2nd Galaxy instance

To deploy a second Galaxy instance on the same cluster, you can use
`sample-values-2nd-deployment.yaml` to provide the necessary configurations.
Before running the following commands, add a new node pool to the existing GKE
cluster, named `pool-2`, then update the values of `persistence.postgres.persistentVolume.extraSpec.csi.volumeHandle` to the correct project id, and then run the following commands:

```console
gcloud compute disks create "nfs-pd-2" --size 300Gi --zone "us-east1-b"
gcloud compute disks create "postgres-pd-2" --size 10Gi --zone "us-east1-b"


helm upgrade --install --create-namespace -n gkmns2 gkm2 . --values sample-values-2nd-deployment.yaml --wait --wait-for-jobs
```

It will take a few minutes for the second Galaxy instance to be ready. The
instance will be deployed It will be available at http://[galaxy-nginx-2 service
external IP]/galaxy/.

## Leo updates
When the GKM chart version changes, need to make a PR to
[Leo](https://github.com/DataBiosphere/leonardo/blob/develop/Dockerfile#L29)
with the updated GKM chart version, any changes to [the variables being passed
there](https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/scala/org/broadinstitute/dsde/workbench/leonardo/util/GKEInterpreter.scala#L1342).
