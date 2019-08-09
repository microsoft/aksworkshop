---

sectionid: frontend
sectionclass: h2
parent-id: upandrunning
title: Deploy the frontend using Ingress
---

You need to deploy the **Frontend** ([azch/frontend](https://hub.docker.com/r/azch/frontend/)). This requires an external endpoint, exposing the website on port 80 and needs to write to connect to the Order Capture API public IP.

### Container images and source code

In the table below, you will find the Docker container images provided by the development team on Docker Hub as well as their corresponding source code on GitHub.

| Component                    | Docker Image                                                     | Source Code                                                       | Build Status |
|------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|--------------|
| Frontend            | [azch/frontend](https://hub.docker.com/r/azch/frontend/) | [source-code](https://github.com/Azure/azch-frontend)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-frontend)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=17) |

### Environment variables

The frontend requires the `CAPTUREORDERSERVICEIP` environment variable to be set to the `captureorder` [service deployed in the previous step](#retrieve-the-external-ip-of-the-service). **Make sure you set this environment variable in your deployment file.**

  * `CAPTUREORDERSERVICEIP="<public IP of order capture service>"`

### Tasks

#### Provision the `frontend` deployment

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

> **Hint** If the pods are not starting, not ready or are crashing, you can view their logs using `kubectl logs <pod name>` and `kubectl describe pod <pod name>`.

{% endcollapsible %}

#### Expose the frontend on a hostname

Instead of accessing the frontend through an IP address, you would like to expose the frontend over a hostname. Explore using [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to achieve this purpose.

As there are many options out there for ingress controllers, we will stick to the tried and true [nginx-ingress](https://github.com/helm/charts/tree/master/stable/nginx-ingress) controller, which is the most popular albeit not the most featureful controller.

* **Ingress controller**: The Ingress controller is exposed to the internet by using a Kubernetes service of type LoadBalancer. The Ingress controller watches and implements Kubernetes Ingress resources, which creates routes to application endpoints.

We will leverage the [nip.io](https://nip.io/) reverse wildcard DNS resolver service to map our ingress controller `LoadBalancerIP` to a proper DNS name.

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

##### Deploy the ingress controller with helm

NGINX ingress controller is easily deployed with helm:

```sh
helm repo update

helm upgrade --install ingress stable/nginx-ingress --namespace ingress
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

If it doesn't work from the first trial, give it a few more minutes or try a different browser.

Note: you might need to enable cross-scripting in your browser; click on the shield icon on the address bar (for Chrome) and allow unsafe script to be executed. 

![Orders frontend](media/ordersfrontend.png)

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
