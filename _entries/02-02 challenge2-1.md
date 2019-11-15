---

sectionid: db
sectionclass: h2
parent-id: upandrunning
title: Deploy MongoDB
---

You need to deploy MongoDB in a way that is scalable and production ready. There are a couple of ways to do so.

**Task Hints**
* Use Helm and a standard provided Helm chart to deploy MongoDB.
* Be careful with the authentication settings when creating MongoDB. It is recommended that you create a standalone username/password. The username and password can be anything you like, but make a note of them for the next task. 

> **Important**: The instructions below are specifically for Helm 2 and will not work with Helm 3. They will be later updated to Helm 3.


> **Important**: If you install using Helm and then delete the release, the MongoDB data and configuration persists in a Persistent Volume Claim. You may face issues if you redeploy again using the same release name because the authentication configuration will not match. If you need to delete the Helm deployment and start over, make sure you delete the Persistent Volume Claims created otherwise you'll run into issues with authentication due to stale configuration. Find those claims using `kubectl get pvc`.

### Tasks

#### Setup Helm

Helm is an application package manager for Kubernetes, and way to easily deploy applications and services into Kubernetes, via what are called charts. To use Helm you will need the `helm` command (already installed in the Azure Cloud Shell), the Tiller component in your cluster which is created with the `helm init` command and a chart to deploy.

#### Initialize the Helm components on the AKS cluster 

**Task Hints**
* Refer to the AKS docs which includes [a guide for setting up Helm in your cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm)
* You *will* have RBAC enabled in your AKS cluster, unless you specifically disabled it when creating it (very unlikely)
* You can ignore the instructions regarding TLS

{% collapsible %}

Unless you specified otherwise your cluster will be RBAC enabled, so you have to create the appropriate `ServiceAccount` for Tiller (the server side Helm component) to use. 

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

Initialize Tiller (omit the ``--service-account`` flag if your cluster is **not** RBAC enabled). Setting `--history-max` on `helm init` is recommended as configmaps and other objects in helm history can grow large in number if not purged by max limit. Without a max history set the history is kept indefinitely, leaving a large number of records for helm and tiller to maintain.

```sh
helm init --history-max 200 --service-account tiller --node-selectors "beta.kubernetes.io/os=linux"
```
{% endcollapsible %}


#### Deploy an instance of MongoDB to your cluster

Helm provides a standard repository of charts for many different software packages, and it has one for [MongoDB](https://github.com/helm/charts/tree/master/stable/mongodb) that is easily replicated and horizontally scalable. 

**Task Hints**
* When installing a chart Helm uses a concept called a "release", and this release needs a name. You should give your release a name (using `--name`), it is strongly recommend you use `orders-mongo` as the name, as we'll need to refer to it later
* When deploying a chart you provide parameters with the `--set` switch and a comma separated list of `key=value` pairs. There are MANY parameters you can provide to the MongoDB chart, but pay attention to the `mongodbUsername`, `mongodbPassword` and `mongodbDatabase` parameters 

> **Note** The application expects a database called `akschallenge`. Please DO NOT modify it.

{% collapsible %}
The recommended way to deploy MongoDB would be to use Helm. 

After you have Tiller initialized in the cluster, wait for a short while then install the MongoDB chart, **then take note of the username, password and endpoints created. The command below creates a user called `orders-user` and a password of `orders-password`**

```sh
helm install stable/mongodb --name orders-mongo --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

> **Hint** By default, the service load balancing the MongoDB cluster would be accessible at ``orders-mongo-mongodb.default.svc.cluster.local``

You'll need to use the user created in the command above when configuring the deployment environment variables.

{% endcollapsible %}

#### Create a Kubernetes secret to hold the MongoDB details

In the previous step, you installed MongoDB using Helm, with a specified username, password and a hostname where the database is accessible. You'll now create a Kubernetes secret called mongodb to hold those details, so that you don't need to hard-code them in the YAML files.

**Task Hints**
* A Kubernetes secret can hold several items, indexed by key. The name of the secret isn't critical, but you'll need three keys stored your secret:
  * `mongoHost`
  * `mongoUser`
  * `mongoPassword`
* The values for the username & password will be what you used on the `helm install` command when deploying MongoDB.
* Run `kubectl create secret generic -h` for help on how to create a secret, clue: use the `--from-literal` parameter to allow you to provide the secret values directly on the command in plain text.
* The value of `mongoHost`, will be dependant on the name of the MongoDB service. The service was created by the Helm chart and will start with the release name you gave. Run `kubectl get service` and you should see it listed, e.g. `orders-mongo-mongodb`
* All services in Kubernetes get DNS names, this is assigned automatically by Kubernetes, there's no need for you to configure it. You can use the short form which is simply the service name, e.g. `orders-mongo-mongodb` or better to use the "fully qualified" form `orders-mongo-mongodb.default.svc.cluster.local`
  
{% collapsible %}

```sh
kubectl create secret generic mongodb --from-literal=mongoHost="orders-mongo-mongodb.default.svc.cluster.local" --from-literal=mongoUser="orders-user" --from-literal=mongoPassword="orders-password"
```

You'll need to use the user created in the command above when configuring the deployment environment variables.

{% endcollapsible %}

> **Resources**
> * <https://www.digitalocean.com/community/tutorials/an-introduction-to-helm-the-package-manager-for-kubernetes>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm>
> * <https://helm.sh/docs/helm/#helm-install>
> * <https://github.com/helm/charts/tree/master/stable/mongodb>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>

### Architecture Diagram
If you want a picture of how the system should look at the end of this challenge click below

<a href="media/architecture/mongo.png" target="_blank"><img src="media/architecture/mongo.png" style="width:500px"></a>
