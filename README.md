# Galaxy KubeMan Helm Chart
Helm chart for Galaxy KubeMan used for deploying Galaxy with NFS (for a multi-node shared filesystem), CVMFS (for Galaxy tool and reference data), and CloudMan (for managing the Galaxy Kubernetes deployment)

## TL;DR on GKE

```console
gcloud container clusters create am-gxy --cluster-version=1.15.7-gke.23 --no-enable-autorepair --disk-size=100 --num-nodes=1 --machine-type=n1-standard-4
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
helm dependency update
kubectl create namespace mynamespace
helm install . --name desired-release-name --namespace mynamespace
```
