---

sectionid: api
sectionclass: h2
parent-id: upandrunning
title: Deploy the Order Capture API
---

You need to deploy the **Order Capture API** application ([azch/captureorder](https://hub.docker.com/r/azch/captureorder/)). This will require an external endpoint, exposing the API so that it can be accessed on port 80. The application will need to write to the MongoDB instance you deployed earlier.

### Container images and source code

In the table below, you will find the Docker container images provided by the development team on Docker Hub as well as their corresponding source code on GitHub.

| Component                    | Docker Image                                                     | Source Code                                                       |
|------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|
| Order Capture API            | [azch/captureorder](https://hub.docker.com/r/azch/captureorder/) | [source-code](https://github.com/Azure/azch-captureorder)         | 

### Environment variables

The Order Capture API requires the following environment variables in order to connect to your MongoDB database. Make sure you set these environment variables in your deployment. You should use the Kubernetes secrets you created earlier to populate the values in the environment variables.

  * `MONGOHOST="<mongodb hostname>"`
  * `MONGOUSER="<mongodb username>"`
  * `MONGOPASSWORD="<mongodb password>"`

> **Hint:** The Order Capture API exposes the following endpoint for health-checks once you have completed the tasks below: `http://[PublicEndpoint]:[port]/healthz`

### Tasks

#### Deploy the `captureorder` application

**Task Hints**
* Read the Kubernetes docs in the resources section below for details on how to create a deployment. You should create a YAML file and use the `kubectl apply -f` command to deploy it to your cluster
* You provide environment variables to your container using the `env` key in your container spec. By using `valueFrom` and `secretRef` you can reference values stored in a Kubernetes secret (i.e. the one you created earlier with the MongoDB host, username and password)
* The container listens on port 8080 
* If your pods are not starting, not ready or are crashing, you can view their logs and detailed status information using `kubectl logs <pod name>` and/or `kubectl describe pod <pod name>`
* Advanced: You can define a `readinessProbe` and `livenessProbe` using the `/healthz` endpoint exposed by the container and the port `8080`, this is optional but considered to be a best practice
* Advanced: It is best practice to define `requests` and `limits` to control the CPU and memory utilisation of your containers

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

> **Hint** If the pods are not starting, not ready or are crashing, you can view their logs and detailed status information using `kubectl logs <pod name>` and `kubectl describe pod <pod name>`.

{% endcollapsible %}

#### Expose the `captureorder` deployment with a service

**Task Hints**
* Read the Kubernetes docs in the resources section below for details on how to create a service. You should create a YAML file and use the `kubectl apply -f` command to deploy it to your cluster
* Pay attention to the `port`, `targetPort` and the `selector`
* Kubernetes has several types of services (described in the docs), specified in the `type` field. You will need to create a service of type `LoadBalancer`
* The service should expose port 80
  
{% collapsible %}

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

**Task Hints**
* The IP of your service will be publicly available on the internet
* The service has a Swagger/OpenAPI definition: `http://[Your Service Public LoadBalancer IP]/swagger`
* The service has an orders endpoint which accepts GET and POST: `http://[Your Service Public LoadBalancer IP]/v1/order`
* Orders take the form `{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}` (The values are not validated)
  
{% collapsible %}

> **Hint:** You can test your deployed API with curl, the Order Capture API's Swagger endpoint or a tool such as [Postman](https://www.getpostman.com/)

Send a `POST` request using curl

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

> **Hint:** In the sample solution, we have specified readinessProbe and livenessProbe settings in the YAML file when we're deploying The Order Capture API. In Kubernetes, readiness probes define when a Container is ready to start accepting traffic, liveness probes monitor the container health. Hence here we can use the following endpoint to do a simple health-checks : `http://[PublicEndpoint]:[port]/healthz`

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/>
> * <https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data>
> * <https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
> * <https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#configuration-file>

### Architecture Diagram
Here's a high level diagram of the components you will have deployed when you've finished this section (click the picture to enlarge)

<a href="media/architecture/captureorder.png" target="_blank"><img src="media/architecture/captureorder.png" style="width:500px"></a>
