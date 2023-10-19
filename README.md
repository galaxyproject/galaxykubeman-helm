# Galaxy on Kubernetes Management (GalaxyKubeMan) Helm Chart
Helm chart for Galaxy KubeMan used for deploying Galaxy with NFS (for a
multi-node shared filesystem), CVMFS (or S3FS) (for Galaxy tool and reference data), and
CloudMan (for managing the Galaxy Kubernetes deployment).

## TL;DR on GKE

```console
gcloud container clusters create example-gke-cluster --cluster-version="1.24" --no-enable-autorepair --disk-size=100 --num-nodes=1 --machine-type=e2-standard-16 --zone "us-east1-b"
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
helm dependency update
helm install --create-namespace --namespace mynamespace desired-release-name . --wait --wait-for-jobs
```

## Leo updates
When the GKM chart version changes, need to make a PR to
[Leo](https://github.com/DataBiosphere/leonardo/blob/develop/Dockerfile#L29)
with the updated GKM chart version, any changes to [the variables being passed
there](https://github.com/DataBiosphere/leonardo/blob/develop/http/src/main/scala/org/broadinstitute/dsde/workbench/leonardo/util/GKEInterpreter.scala#L1342).
