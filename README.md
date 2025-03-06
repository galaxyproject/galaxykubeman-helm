# Galaxy on Kubernetes Management (GalaxyKubeMan) Helm Chart
Helm chart for GalaxyKubeMan (GKM) used for deploying Galaxy on GKE/AnVIL.

## TL;DR on GKE

We first launch a cluster, then install a dependencies chart that deploys
necessary operators, create a persistent disk, and then install GKM, which will
install Galaxy.

The `sample-values.yaml` file contains the values to deploy a test/dev version
of GKM. In addition, you will need to copy `sample-auth.yaml` to the `templates`
folder before deploying a dev instance.

```console
gcloud container clusters create example-gke-cluster --cluster-version="1.30" --no-enable-autorepair --disk-size=200 --num-nodes=1 --machine-type=e2-standard-16 --zone "us-east1-b"

helm repo add cloudve https://raw.githubusercontent.com/CloudVE/helm-charts/master/
helm repo update
helm install --create-namespace -n "galaxy-deps" galaxy-deps cloudve/galaxy-deps --set cvmfs.cvmfscsi.nodeplugin.priorityClassName=""

gcloud compute disks create "nfs-pd" --size 300Gi --zone "us-east1-b"

git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
cp sample-auth.yaml templates/auth.yaml
helm dependency update
helm upgrade --install --create-namespace -n gkmns gkm . --values sample_values.yaml --wait --wait-for-jobs
```

It will take about 5 minutes for the Galaxy instance to be ready. It will be available at http://[galaxy-nginx service external IP]/galaxy/.

## Leo updates
When the GKM chart version changes, need to make a PR to
[Leo](https://github.com/DataBiosphere/leonardo/blob/develop/Dockerfile#L29)
with the updated GKM chart version, any changes to [the variables being passed
there](https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/scala/org/broadinstitute/dsde/workbench/leonardo/util/GKEInterpreter.scala#L1342).
