# Galaxy on Kubernetes Management (GalaxyKubeMan) Helm Chart
Helm chart for Galaxy KubeMan used for deploying Galaxy with NFS (for a multi-node shared filesystem), CVMFS (for Galaxy tool and reference data), and CloudMan (for managing the Galaxy Kubernetes deployment)

## TL;DR on GKE

```console
gcloud container clusters create example-gke-cluster --cluster-version=1.15.9-gke.24 --no-enable-autorepair --disk-size=100 --num-nodes=2 --machine-type=n1-standard-4
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
helm dependency update
kubectl create namespace mynamespace
helm install desired-release-name . --namespace mynamespace
```

## Leo updates
When the GKM chart version changes, need to make a PR to
[Leo](https://github.com/DataBiosphere/leonardo/blob/develop/Dockerfile#L29)
with the updated GKM chart version, any changes to [the variables being passed
there](https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/scala/org/broadinstitute/dsde/workbench/leonardo/util/GKEInterpreter.scala#L1342).
