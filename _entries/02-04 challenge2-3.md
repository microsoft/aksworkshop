---

sectionid: frontend
sectionclass: h2
parent-id: upandrunning
title: Deploy the frontend using Ingress
---

You need to deploy the **Frontend** application ([azch/frontend](https://hub.docker.com/r/azch/frontend/)). This requires an external endpoint, exposing the website on port 80 and it needs to connect to the Order Capture API's public IP address so that it can display the number of orders in the system.

We want to access the Frontend application using a DNS hostname rather than an IP address. 

### Container images and source code

In the table below, you will find the Docker container images provided by the development team on Docker Hub as well as their corresponding source code on GitHub.

| Component                    | Docker Image                                                     | Source Code                                                       | 
|------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|
| Frontend            | [azch/frontend](https://hub.docker.com/r/azch/frontend/) | [source-code](https://github.com/Azure/azch-frontend)         |

### Environment variables

The frontend requires the `CAPTUREORDERSERVICEIP` environment variable to be set to the external public IP address of the `captureorder` [service deployed in the previous step](#retrieve-the-external-ip-of-the-service). **Make sure you set this environment variable in your deployment file.**

  * `CAPTUREORDERSERVICEIP="<public IP of order capture service>"`

### Tasks

#### Deploy the `frontend` application

**Task Hints**
* As with the captureorder deployment you will need to create a YAML file which describes your deployment. Making a copy of your captureorder deployment YAML would be a good start, but beware you will need to change
  * `image`
  * `readinessProbe` endpoint, if you have one (clue use the root url '/')
  * `livenessProbe` endpoint, if you have one (clue use the root url '/')
* As before you need to provide environmental variables to your container using `env`, but this time nothing is stored in a secret
* The container listens on port 8080 
* If your pods are not starting, not ready or are crashing, you can view their logs and detailed status information using `kubectl logs <pod name>` and/or `kubectl describe pod <pod name>`
  
{% collapsible %}

##### Deployment

Save the YAML below as `frontend-deployment.yaml` or download it from [frontend-deployment.yaml](yaml-solutions/01. challenge-02/frontend-deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  selector:
      matchLabels:
        app: frontend
  replicas: 1
  template:
      metadata:
        labels:
            app: frontend
      spec:
        containers:
        - name: frontend
          image: azch/frontend
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              port: 8080
              path: /
          livenessProbe:
            httpGet:
              port: 8080
              path: /
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          env:
          - name: CAPTUREORDERSERVICEIP
            value: "<public IP of order capture service>" # Replace with your captureorder service IP
          ports:
          - containerPort: 8080
```

And deploy it using

```sh
kubectl apply -f frontend-deployment.yaml
```

##### Verify that the pods are up and running

```sh
kubectl get pods -l app=frontend -w
```

> **Hint** If the pods are not starting, not ready or are crashing, you can view their logs and detailed status information using `kubectl logs <pod name>` and `kubectl describe pod <pod name>`.

{% endcollapsible %}

#### Expose the frontend using a hostname

Instead of accessing the frontend through an IP address, you would like to expose the frontend using a hostname. Explore using [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to achieve this.

There are many options when considering Kubernetes ingress controllers, including the [Azure Application Gateway Ingress Controller](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)  The most commonly used is the [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) controller.

> The Ingress controller is exposed to the internet by using a Kubernetes service of type LoadBalancer. The Ingress controller watches and implements Kubernetes Ingress resources, which creates routes to application endpoints.

We can leverage the [nip.io](https://nip.io/) reverse wildcard DNS resolver service to map our ingress controller's `LoadBalancerIP` to a proper DNS name.

**Task Hints**
* When placing services behind an ingress you don't expose them directly with the `LoadBalancer` type, instead you use a `ClusterIP`. In this network model, external clients access your service via public IP of the *ingress controller*, which then decides where to route the traffic within your Kubernetes cluster.
* [This picture helps explain how this works](media/architecture/ingress.png)
* Use Helm to deploy The NGINX ingress controller. [The Helm chart for the NGINX ingress controller](https://github.com/helm/charts/tree/master/stable/nginx-ingress) requires no options/values when deploying it.
* ProTip: Place the ingress controller in a different namespace, e.g. `ingress` by using the `--namespace` option.
* Use `kubectl get service` (add `--namespace` if you deployed it to a different namespace) to discover the public/external IP of your ingress controller, you will need to make a note of it. the
* [nip.io](https://nip.io) is not related to Kubernetes or Azure, however it provides a useful service to map any IP Address to a hostname. This saves you having to create public DNS records. If your ingress controller had IP 12.34.56.78, you could access it via `http://anythingyouwant.12.34.56.78.nip.io`
* The [Kubernetes docs have an example of creating an Ingress object](https://kubernetes.io/docs/concepts/services-networking/ingress/#name-based-virtual-hosting), except you will only be specifying a single host rule. Use nip.io and your ingress controller IP to set the `host` field. As with the deployment and service, you create this object via a YAML file and `kubectl apply`

{% collapsible %}

##### Service

Save the YAML below as `frontend-service.yaml` or download it from [frontend-service.yaml](yaml-solutions/01. challenge-02/frontend-service.yaml)

> **Note** Since you're going to expose the deployment using an Ingress, there is no need to use a public IP for the Service, hence you can set the type of the service to be `ClusterIP` instead of `LoadBalancer`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
```

And deploy it using

```sh
kubectl apply -f frontend-service.yaml
```

##### Deploy the ingress controller with Helm

Create a namespace for the ingress

```sh
kubectl create namespace ingress
```

NGINX ingress controller is easily deployed with Helm:

```sh
helm repo update

helm install ingress stable/nginx-ingress --namespace ingress
```

In a couple of minutes, a public IP address will be allocated to the ingress controller, retrieve with:

```sh
kubectl get svc  -n ingress    ingress-nginx-ingress-controller -o jsonpath="{.status.loadBalancer.ingress[*].ip}"
```

##### Ingress

Create an Ingress resource that is annotated with the required annotation and make sure to replace `_INGRESS_CONTROLLER_EXTERNAL_IP_` with the IP address  you retrieved from the previous command.

Additionally, make sure that the `serviceName` and `servicePort` are pointing to the correct values as the Service you deployed previously.

Save the YAML below as `frontend-ingress.yaml` or download it from [frontend-ingress.yaml](yaml-solutions/01. challenge-02/frontend-ingress.yaml)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: frontend._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io
    http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
        path: /
```

And create it using

```sh
kubectl apply -f frontend-ingress.yaml
```

{% endcollapsible %}

#### Browse to the public hostname of the frontend and watch as the number of orders change

Once the Ingress is deployed, you should be able to access the frontend at <http://frontend.[cluster_specific_dns_zone]>, for example <http://frontend.52.255.217.198.nip.io>

If it doesn't work on the first attempt, give it a few more minutes or try a different browser.

Note: you might need to enable cross-site scripting in your browser; click on the shield icon on the address bar (for Chrome) and allow unsafe script to be executed. 

![Orders frontend](media/ordersfrontend.png)

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
> * <https://kubernetes.io/docs/concepts/services-networking/ingress/>
> * <https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/>

### Architecture Diagram
Here's a high level diagram of the components you will have deployed when you've finished this section (click the picture to enlarge)

<a href="media/architecture/frontend.png" target="_blank"><img src="media/architecture/frontend.png" style="width:500px"></a>
