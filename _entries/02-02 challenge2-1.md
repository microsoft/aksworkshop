---

sectionid: db
sectionclass: h2
parent-id: upandrunning
title: Deploy MongoDB
---

You need to deploy MongoDB in a way that is scalable and production ready. There are a couple of ways to do so.

> **Hints**
> * Be careful with the authentication settings when creating MongoDB. It is recommended that you create a standalone username/password and database.
> * **Important**: If you install using Helm and then delete the release, the MongoDB data and configuration persists in a Persistent Volume Claim. You may face issues if you redploy again using the same release name because the authentication configuration will not match. If you need to delete the Helm deployment and start over, make sure you delete the Persistent Volume Claims created otherwise you'll run into issues with authentication due to stale configuration. Find those claims using `kubectl get pvc`.

### Tasks

#### Deploy an instance of MongoDB to your cluster. The application expects a database called `akschallenge`

{% collapsible %}
The recommended way to deploy MongoDB would be to use Helm. Helm is a Kubernetes application package manager and it has a [MongoDB Helm chart](https://github.com/helm/charts/tree/master/stable/mongodb#production-settings-and-horizontal-scaling) that is replicated and horizontally scalable.

##### Install Helm on your developer machine

Follow the instructions here <https://docs.helm.sh/using_helm/#from-the-binary-releases>

##### Initialize the Helm components on the AKS cluster (RBAC enabled AKS cluster, default behaviour of CLI, optional behavior from the Azure Portal)

If the cluster is RBAC enabled, you have to create the appropriate `ServiceAccount` for Tiller (the server side Helm component) to use.

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

And deploy it using

```sh
kubectl apply -f helm-rbac.yaml
```

Initialize Tiller (ommit the ``--service-account`` flag if your cluster is **not** RBAC enabled)

```sh
helm init --service-account tiller
```

##### Install the MongoDB Helm chart

After you Tiller initialized in the cluster, wait for a short while then install the MongoDB chart, **then take note of the username, password and endpoints created. The command below creates a user called `orders-user` and a password of `orders-password`**

```sh
helm install stable/mongodb --name orders-mongo --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

> **Hint**
> * By default, the service load balancing the MongoDB cluster would be accessible at ``orders-mongo-mongodb.default.svc.cluster.local``

You'll need to use the user created in the command above when configuring the deployment environment variables.
{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm>
> * <https://github.com/helm/charts/tree/master/stable/mongodb#replication>
