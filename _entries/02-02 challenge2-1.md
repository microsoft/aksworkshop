---

sectionid: db
sectionclass: h2
parent-id: upandrunning
title: Deploy MongoDB
---

You need to deploy MongoDB in a way that is scalable and production ready.

**Task Hints**
* Use Helm and a standard provided Helm chart to deploy MongoDB.
* Be careful with the authentication settings when creating MongoDB. It is recommended that you create a standalone username/password. The username and password can be anything you like, but make a note of them for the next task. 

> **Important**: If you install using Helm and then delete the release, the MongoDB data and configuration persists in a Persistent Volume Claim. You may face issues if you redeploy again using the same release name because the authentication configuration will not match. If you need to delete the Helm deployment and start over, make sure you delete the Persistent Volume Claims created otherwise you'll run into issues with authentication due to stale configuration. Find those claims using `kubectl get pvc`.

### Tasks

#### Setup Helm

Helm is an application package manager for Kubernetes, and a way to easily deploy applications and services into Kubernetes, via what are called charts. To use Helm you will need the `helm` command (This is already installed if you're using the Azure Cloud Shell).

**Task Hints**
* These instructions use [Helm version 3](https://helm.sh/blog/helm-3-released/).
* Helm version 3 does not come with any repositories predefined, so you'll need initialize the [stable chart repository](https://v3.helm.sh/docs/intro/quickstart/#initialize-a-helm-chart-repository)

{% collapsible %}

Add the `stable` Helm charts repository
`helm repo add stable https://kubernetes-charts.storage.googleapis.com/`

Upate the repositories
`helm repo update`

{% endcollapsible %}



#### Deploy an instance of MongoDB to your cluster

A standard repository of Helm charts is available for many different software packages, and it has one for [MongoDB](https://github.com/helm/charts/tree/master/stable/mongodb) that is easily replicated and horizontally scalable. 

**Task Hints**
* When installing a chart, Helm uses a concept called a "release" and each release needs a name. We recommend you name your release `orders-mongo` to make it easier to follow later steps in this workshop
* When deploying a chart you provide parameters with the `--set` switch and a comma separated list of `key=value` pairs. There are MANY parameters you can provide to the MongoDB chart, but pay attention to the `mongodbUsername`, `mongodbPassword` and `mongodbDatabase` parameters 

> **Note** The application expects a database named `akschallenge`. Using a different database name will cause the application to fail!

{% collapsible %}
The recommended way to deploy MongoDB would be to use a Helm Chart. 

```sh
helm install orders-mongo stable/mongodb --set mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

> **Hint** Using this command, the Helm Chart will expose the MongoDB instance as a Kubernetes Service accessible at ``orders-mongo-mongodb.default.svc.cluster.local``

Remember to use the username and password from the command above when creating the Kubernetes secrets in the next step.

{% endcollapsible %}

#### Create a Kubernetes secret to hold the MongoDB details

In the previous step, you installed MongoDB using Helm, with a specified username, password and a hostname where the database is accessible. You'll now create a Kubernetes secret called `mongodb` to hold those details, so that you don't need to hard-code them in the YAML files.

**Task Hints**
* A Kubernetes secret can hold several items, indexed by key. The name of the secret isn't critical, but you'll need three keys to store your secret data:
  * `mongoHost`
  * `mongoUser`
  * `mongoPassword`
* The values for the username & password will be those you used with the `helm install` command when deploying MongoDB.
* Run `kubectl create secret generic -h` for help on how to create a secret, clue: use the `--from-literal` parameter to allow you to provide the secret values directly on the command in plain text.
* The value of `mongoHost`, will be dependent on the name of the MongoDB service. The service was created by the Helm chart and will start with the release name you gave. Run `kubectl get service` and you should see it listed, e.g. `orders-mongo-mongodb`
* All services in Kubernetes get DNS names, this is assigned automatically by Kubernetes, there's no need for you to configure it. You can use the short form which is simply the service name, e.g. `orders-mongo-mongodb` or better to use the "fully qualified" form `orders-mongo-mongodb.default.svc.cluster.local`
  
{% collapsible %}

```sh
kubectl create secret generic mongodb --from-literal=mongoHost="orders-mongo-mongodb.default.svc.cluster.local" --from-literal=mongoUser="orders-user" --from-literal=mongoPassword="orders-password"
```

You'll need to reference this secret when configuring the Order Capture application later on.

{% endcollapsible %}

> **Resources**
> * <https://helm.sh/docs/intro/using_helm/>
> * <https://github.com/helm/charts/tree/master/stable/mongodb>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>

### Architecture Diagram
Here's a high level diagram of the components you will have deployed when you've finished this section (click the picture to enlarge)

<a href="media/architecture/mongo.png" target="_blank"><img src="media/architecture/mongo.png" style="width:500px"></a>

* The **pod** holds the containers that run MongoDB
* The **deployment** manages the pod
* The **service** exposes the pod to the Internet using a public IP address and a specified port
