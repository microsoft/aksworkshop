---

sectionid: api
sectionclass: h2
parent-id: upandrunning
title: Deploy the frontend
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

#### Provision the `frontend` deployment and expose a public endpoint

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
          - containerPort: 80
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

##### Service

Save the YAML below as `frontend-service.yaml` or download it from [frontend-service.yaml](yaml-solutions/01. challenge-02/frontend-service.yaml)

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
  type: LoadBalancer
```

And deploy it using

```sh
kubectl apply -f frontend-service.yaml
```

##### Retrieve the External-IP of the Service

Use the command below. Make sure to allow a couple of minutes for the Azure Load Balancer to assign a public IP.

```sh
kubectl get service frontend -o jsonpath="{.status.loadBalancer.ingress[*].ip}"
```

{% endcollapsible %}

#### Browse to the public IP of the frontend and watch as the number of orders change

{% collapsible %}
Browse to <http://[frontend public service ip]/>

![Orders frontend](media/ordersfrontend.png)

{% endcollapsible %}

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
