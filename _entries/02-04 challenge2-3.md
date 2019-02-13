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

The frontend requires certain environment variables to properly run and track your progress. Make sure you set those environment variables.

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
            value: "<public IP of order capture service>"
          ports:
          - containerPort: 8080
```

And deploy it using

```sh
kubectl apply -f frontend-deployment.yaml
```

##### Verify that the pods are up and running

```sh
kubectl get pods -l app=frontend
```

> **Hint** If the pods are not starting, not ready or are crashing, you can view their logs using `kubectl logs <pod name>` and `kubectl describe pod <pod name>`.

{% endcollapsible %}

#### Expose the frontend on a hostname

Instead of accessing the frontend through an IP address, you would like to expose the frontend over a hostname. Explore using [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) with [AKS HTTP Application Routing add-on](https://docs.microsoft.com/en-us/azure/aks/http-application-routing) to achieve this purpose.

When you enable the add-on, this deploys two components:a [Kubernetes Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress/) and an [External-DNS](https://github.com/kubernetes-incubator/external-dns) controller.

* **Ingress controller**: The Ingress controller is exposed to the internet by using a Kubernetes service of type LoadBalancer. The Ingress controller watches and implements Kubernetes Ingress resources, which creates routes to application endpoints.
* **External-DNS controller**: Watches for Kubernetes Ingress resources and creates DNS A records in the cluster-specific DNS zone using Azure DNS.

{% collapsible %}

##### Enable the HTTP routing add-on on your cluster

```sh
az aks enable-addons --resource-group akschallenge --name <unique-aks-cluster-name> --addons http_application_routing
```

This will take a few minutes.

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

##### Ingress

The HTTP application routing add-on may only be triggered on Ingress resources that are annotated as follows:

```yaml
annotations:
  kubernetes.io/ingress.class: addon-http-application-routing
```

Retrieve your cluster specific DNS zone name by running the command below

```sh
az aks show --resource-group akschallenge --name <unique-aks-cluster-name> --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```

You should get back something like `9f9c1fe7-21a1-416d-99cd-3543bb92e4c3.eastus.aksapp.io`.

Create an Ingress resource that is annotated with the required annotation and make sure to replace `<CLUSTER_SPECIFIC_DNS_ZONE>` with the DNS zone name you retrieved from the previous command.

Additionally, make sure that the `serviceName` and `servicePort` are pointing to the correct values as the Service you deployed previously.

Save the YAML below as `frontend-ingress.yaml` or download it from [frontend-ingress.yaml](yaml-solutions/01. challenge-02/frontend-ingress.yaml)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
spec:
  rules:
  - host: frontend.<CLUSTER_SPECIFIC_DNS_ZONE>
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

#### Verify that the DNS records are created

{% collapsible %}

View the logs of the External DNS pod

```sh
kubectl logs -f deploy/addon-http-application-routing-external-dns -n kube-system
```

It should say something about updating the A record. It may take a few minutes.

```sh
time="2019-02-13T01:58:25Z" level=info msg="Updating A record named 'frontend' to '13.90.199.8' for Azure DNS zone 'b3ec7d3966874de389ba.eastus.aksapp.io'."
time="2019-02-13T01:58:26Z" level=info msg="Updating TXT record named 'frontend' to '"heritage=external-dns,external-dns/owner=default"' for Azure DNS zone 'b3ec7d3966874de389ba.eastus.aksapp.io'."
```

You should also be able to find the new records created in the Azure DNS zone for your cluster.

![Azure DNS](media/dns.png)

{% endcollapsible %}

#### Browse to the public hostname of the frontend and watch as the number of orders change

Once the Ingress is deployed and the DNS records propagated, you should be able to access the frontend at <http://frontend.[cluster_specific_dns_zone]>, for example <http://frontend.9f9c1fe7-21a1-416d-99cd-3543bb92e4c3.eastus.aksapp.io>

If it doesn't work from the first trial, give it a few more minutes or try a different browser.

![Orders frontend](media/ordersfrontend.png)

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
