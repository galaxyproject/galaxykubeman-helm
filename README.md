# Galaxy on Kubernetes Management (GalaxyKubeMan) Helm Chart
Helm chart for GalaxyKubeMan (GKM) used for deploying Galaxy on GKE/AnVIL.

## Creating a GKE cluster and deploying dependencies

Start by launching a GKE cluster, then install the Galaxy dependencies chart that deploys
necessary operators, as well as create persistent disks.

```console
gcloud container clusters create example-gke-cluster --cluster-version="1.30" --no-enable-autorepair --disk-size=200 --num-nodes=1 --machine-type=e2-standard-16 --zone "us-east1-b"


helm repo add cloudve https://raw.githubusercontent.com/CloudVE/helm-charts/master/
helm repo update
helm install --create-namespace -n "galaxy-deps" galaxy-deps cloudve/galaxy-deps --set cvmfs.cvmfscsi.nodeplugin.priorityClassName="" --set postgresql.deploy=false

gcloud compute disks create "nfs-pd" --size 300Gi --zone "us-east1-b"
gcloud compute disks create "postgres-pd" --size 10Gi --zone "us-east1-b"
```

## Deploying a new Galaxy instance

Once the cluster is created, you can deploy a new Galaxy instance. The
`sample-values.yaml` file contains sample values to deploy a test/dev version
with no/minimal configuration. Consider the following changes:

- If you changed the names or the persistent disks from the instructions above,
  just update those values in `persistence.[nfs,
  postgres].persistentVolume.extraSpec.gcePersistentDisk.pdName`;
- If you plan on changing the release name from `gkm` used in the helm command
  below, set the value of `galaxy.persistence.existingDatabase` to `{{
  release-name }}-postgresql` using the string literal, and not a template
  variable.
- If you plan on changing the release name from `gkm` used in the helm command
  below, set the value of `galaxy.persistence.galaxyExistingSecret` to `{{
  release-name }}-postgresql` using the string literal, and not a template
  variable.

Then run the following commands:

```console
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
cp sample-auth.yaml templates/auth.yaml
helm dependency update
helm upgrade --install --create-namespace -n gkmns gkm . --values sample-values.yaml --wait --wait-for-jobs
```

It will take about 5 minutes for the Galaxy instance to be ready. It will be available at http://[galaxy-nginx service external IP]/galaxy/.

## Deleting a Galaxy instance

**Note:** If you will want to redeploy an existing instance (ie, keep the data),
before deleting it, make sure to record the ID of the Galaxy PVC.

To delete a Galaxy instance, run the following command:

```console
helm del gkm -n gkmns
```

## Redeploying a Galaxy instance
If you want to redeploy a Galaxy instance, meaning create a new instance but
with data from an earlier installation, it is necessary to update the following
values before installing the chart:

- Set `restore.persistence.nfs.galaxy.pvcID` to the PVC ID of the old PVC from
the previous Galaxy instance;
- Set `galaxy.persistence..existingClaim` to `{{release-name}}-galaxy-galaxy-pvc`. You must use a literal string here, and not a template variable;
- Set `galaxy.persistence.storageClass to -

Then run the `helm upgrade` command again with the same parameters as above.

## Deploying 2nd Galaxy instance on the same cluster

To deploy a second Galaxy instance on the same cluster, first add a node pool to the cluster (call is `pool-2` if you want to minimize changes to the sample values) as well as create a second set of GCP persistent disks:

```console
gcloud compute disks create "nfs-pd-2" --size 300Gi --zone "us-east1-b"
gcloud compute disks create "postgres-pd-2" --size 10Gi --zone "us-east1-b"
```

Sample values are available in `sample-values-2nd-deployment.yaml` with the
necessary configurations. Consider the following values changes:

- If you changed the names of persistent disks, update `persistence.[nfs,
postgres].persistentVolume.extraSpec.gcePersistentDisk.pdName` to the names of
your GCP persistent disks;
- Set the value of `galaxy.persistence.existingDatabase` to `{{ release-name }}-postgresql` using the string literal, and not a template variable.
- Set the value of `galaxy.persistence.galaxyExistingSecret` to `{{ release-name }}-postgresql` using the string literal, and not a template variable.

Then run the following commands:

```console
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
