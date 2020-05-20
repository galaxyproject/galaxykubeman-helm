# Galaxy KubeMan Helm Chart
Helm chart for Galaxy KubeMan used for deploying Galaxy with NFS (for a multi-node shared filesystem), CVMFS (for Galaxy tool and reference data), and CloudMan (for managing the Galaxy Kubernetes deployment)

## TL;DR on GKE with Helm3

```console
gcloud container clusters create example-gke-cluster --cluster-version=1.15.9-gke.24 --no-enable-autorepair --disk-size=100 --num-nodes=2 --machine-type=n1-standard-4
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
helm dependency update
kubectl create namespace mynamespace
helm install desired-release-name . --namespace mynamespace
```

## TL;DR on GKE with Helm2

```console
gcloud container clusters create example-gke-cluster --cluster-version=1.15.9-gke.24 --no-enable-autorepair --disk-size=100 --num-nodes=2 --machine-type=n1-standard-4
git clone https://github.com/galaxyproject/galaxykubeman-helm
cd galaxykubeman-helm/galaxykubeman
helm dependency update
kubectl create namespace mynamespace
helm install . --name desired-release-name --namespace mynamespace
```
