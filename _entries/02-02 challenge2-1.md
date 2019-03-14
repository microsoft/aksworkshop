---

sectionid: db
sectionclass: h2
parent-id: upandrunning
title: Deploy MongoDB
---

Our application needs access to an instance of MongoDB for persistence. This section will walk you through installing MongoDB using Helm, a package manager for Kubenretes.

> **Hints**
> * Be careful with the authentication settings when creating MongoDB. It is recommended that you create a standalone username/password and database.
> * **Important**: If you install using Helm and then delete the release, the MongoDB data and configuration persists in a Persistent Volume Claim. You may face issues if you redploy again using the same release name because the authentication configuration will not match. If you need to delete the Helm deployment and start over, make sure you delete the Persistent Volume Claims created otherwise you'll run into issues with authentication due to stale configuration. Find those volume claims using `kubectl get pvc`.

### Tasks

#### Deploy MongoDB to your cluster

The recommended way to deploy MongoDB would be to use Helm. Helm is a Kubernetes application package manager and it has a [MongoDB Helm chart](https://github.com/helm/charts/tree/master/stable/mongodb#production-settings-and-horizontal-scaling) that is replicated and horizontally scalable.


#### Install Helm on the AKS cluster
{% collapsible %}

Tiller, the server-side component with which Helm communicates, needs to use a `ServiceAccount` to authenticate to your AKS cluster. For this lab, the `ServiceAccount` will have full cluster access:

Save the YAML below as `helm-rbac.yaml` or download it from [helm-rbac.yaml](yaml-solutions/01. challenge-02/helm-rbac.yaml)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

And create the `ServiceAccount` and RBAC roles using `kubectl apply`

```sh
kubectl apply -f helm-rbac.yaml
```

Use `helm init` to install Tiller

```sh
helm init --service-account tiller
```

{% endcollapsible %}

#### Install the MongoDB Helm chart

Install MongoDB using Helm.

{% collapsible %}

After running `helm init` tiller will start in the background. Kubernetes will take a few moments to download the tiller image and launch the process.

When `helm version` returns without an error tiller is ready to install charts.

Install MongoDB in your cluster, using an upstream MongoDB chart. The following helm command creates a user called `orders-user` and a password of `orders-password`.

Note that application expects a database named `akschallenge`.

```
To reset mongodb run:
	helm delete --purge orders-mongo
```



```sh

helm install stable/mongodb --name orders-mongo \
  --set persistence.enabled=false,mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

> **Hint**
> * By default, MongoDB will be available within your cluster with the hostname `orders-mongo-mongodb.default.svc.cluster.local`

Later, configure your application with the username and password used in the `helm install` command.

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm>
> * <https://github.com/helm/charts/tree/master/stable/mongodb#replication>
