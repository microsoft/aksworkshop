---

sectionid: api
sectionclass: h2
parent-id: upandrunning
title: Deploy the Order Capture API
---

You need to deploy the **Order Capture API** ([azch/captureorder](https://hub.docker.com/r/azch/captureorder/)). This requires an external endpoint, exposing the API on port 80 and needs to write to MongoDB.

### Container images and source code

In the table below, you will find the Docker container images provided by the development team on Docker Hub as well as their corresponding source code on GitHub.

| Component                    | Docker Image                                                     | Source Code                                                       | Build Status |
|------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|--------------|
| Order Capture API            | [azch/captureorder](https://hub.docker.com/r/azch/captureorder/) | [source-code](https://github.com/Azure/azch-captureorder)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-captureorder)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=10) |

### Environment variables

The Order Capture API requires certain environment variables to properly run and track your progress. Make sure you set those environment variables.

  * `MONGOHOST="<hostname of mongodb>"`
    * MongoDB hostname. Read from a Kubernetes secret called **mongodb**.
  * `MONGOUSER="<mongodb username>"`
    * MongoDB username. Read from a Kubernetes secret called **mongodb**.
  * `MONGOPASSWORD="<mongodb password>"`
    * MongoDB password. Read from a Kubernetes secret called **mongodb**.

> **Hint:** The Order Capture API exposes the following endpoint for health-checks once you have completed the tasks below: `http://[PublicEndpoint]:[port]/healthz`

### Tasks

#### Provision the `captureorder` deployment and expose a public endpoint

{% collapsible %}

##### Deployment

Save the YAML below as `captureorder-deployment.yaml` or download it from [captureorder-deployment.yaml](yaml-solutions/01. challenge-02/captureorder-deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: captureorder
spec:
  selector:
      matchLabels:
        app: captureorder
  replicas: 2
  template:
      metadata:
        labels:
            app: captureorder
      spec:
        containers:
        - name: captureorder
          image: azch/captureorder
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              port: 8080
              path: /healthz
          livenessProbe:
            httpGet:
              port: 8080
              path: /healthz
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          env:
          - name: MONGOHOST
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoHost
          - name: MONGOUSER
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoUser
          - name: MONGOPASSWORD
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoPassword
          ports:
          - containerPort: 8080
```

And deploy it using

```sh
kubectl apply -f captureorder-deployment.yaml
```

##### Verify that the pods are up and running

```sh
kubectl get pods -l app=captureorder -w
```

Wait until you see pods are in the `Running` state.

> **Hint** If the pods are not starting, not ready or are crashing, you can view their logs using `kubectl logs <pod name>` and `kubectl describe pod <pod name>`.

##### Service

Save the YAML below as `captureorder-service.yaml` or download it from [captureorder-service.yaml](yaml-solutions/01. challenge-02/captureorder-service.yaml)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: captureorder
spec:
  selector:
    app: captureorder
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

And deploy it using

```sh
kubectl apply -f captureorder-service.yaml
```

##### Retrieve the External-IP of the Service

Use the command below. **Make sure to allow a couple of minutes** for the Azure Load Balancer to assign a public IP.

```sh
kubectl get service captureorder -o jsonpath="{.status.loadBalancer.ingress[*].ip}" -w
```

{% endcollapsible %}

#### Ensure orders are successfully written to MongoDB

{% collapsible %}

> **Hint:** You can test your deployed API either by using Postman or Swagger with the following endpoint : `http://[Your Service Public LoadBalancer IP]/swagger/`

Send a `POST` request using [Postman](https://www.getpostman.com/) or curl to the IP of the service you got from the previous command

```sh
curl -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -X POST http://[Your Service Public LoadBalancer IP]/v1/order
```

You can expect the order ID returned by API once your order has been written into Mongo DB successfully

```json
{
    "orderId": "5beaa09a055ed200016e582f"
}
```

{% endcollapsible %}

> **Hint:** You may notice we have deployed readinessProbe and livenessProbe in the YAML file when we're deploying The Order Capture API. In Kubernetes, readiness probes define when a Container is ready to start accepting traffic, liveness probes monitor the container health. Hence here we can use the following endpoint to do a simple health-checks : `http://[PublicEndpoint]:[port]/healthz`

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
