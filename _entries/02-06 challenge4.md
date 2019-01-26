---
sectionid: scaling
sectionclass: h2
parent-id: upandrunning
title: Scaling
---

As popularity of the application grows the application needs to scale appropriately as demand changes.
Ensure the application remains responsive as the number of order submissions increases.

### Tasks

#### Run a baseline load test

{% collapsible %}
There is a a container image on Docker Hub ([azch/loadtest](https://hub.docker.com/r/azch/loadtest)) that is preconfigured to run the load test. You may run it in [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) running the command below

```sh
az container create -g akschallenge -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_IP=<public ip of order capture service>
```

This will fire off a series of increasing loads of concurrent users (100, 400, 1600, 3200, 6400) POSTing requests to your Order Capture API endpoint with some wait time in between to simulate an increased pressure on your application.

You may view the logs of the Azure Container Instance streaming logs by running the command below. You may need to wait for a few minutes to get the full logs, or run this command multiple times.

```sh
az container logs -g akschallenge -n loadtest
```

When you're done, you may delete it by running

```sh
az container delete -g akschallenge -n loadtest
```

Make note of results (sample below), figure out what is the breaking point for the number of users.

```
Phase 5: Load test - 30 seconds, 6400 users.

Summary:
  Total:	41.1741 secs
  Slowest:	23.7166 secs
  Fastest:	0.8882 secs
  Average:	9.7952 secs
  Requests/sec:	569.1929

  Total data:	1003620 bytes
  Size/request:	43 bytes

Response time histogram:
  0.888 [1]	|
  3.171 [1669]	|■■■■■■■■■■■■■■
  5.454 [1967]	|■■■■■■■■■■■■■■■■■
  7.737 [4741]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  10.020 [3660]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  12.302 [3786]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  14.585 [4189]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  16.868 [2583]	|■■■■■■■■■■■■■■■■■■■■■■
  19.151 [586]	|■■■■■
  21.434 [151]	|■
  23.717 [7]	|

Status code distribution:
  [200]	23340 responses

Error distribution:
  [96]	Post http://23.96.91.35/v1/order: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
```

You may use the Azure Monitor (previous task) to view the logs and figure out where you need to optimize to increase the throughtput (requests/sec), reduce the average latency and error count.

![Azure Monitor container insights](media/captureorder-loadtest-log.png)

{% endcollapsible %}

#### Create Horizontal Pod Autoscaler

Most likely in your initial test, the `captureorder` container was the bottleneck. So the first step would be to scale it out. There are two ways to do so, you can either manually increase the number of replicas in the deployment, or use Horizontal Pod Autoscaler.

Horizontal Pod Autoscaler allows Kubernetes to detect when your deployed pods need more resources and then it schedules more pods onto the cluster to cope with the demand.

{% collapsible %}

Save the YAML below as `captureorder-hpa.yaml` or download it from [captureorder-hpa.yaml](yaml-solutions/01. challenge-04/captureorder-hpa.yaml)

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: captureorder
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: captureorder
  minReplicas: 4
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

And deploy it using

```sh
kubectl apply -f captureorder-hpa.yaml
```

> **Important** For the Horizontal Pod Autoscaler to work, you **MUST** remove the explicit `replicas: 2` count from your `captureorder` deployment and redeploy it and your pods must define resource requests and resource limits.

{% endcollapsible %}

#### Run a load test again after applying Horizontal Pod Autoscaler

{% collapsible %}

If you didn't delete the load testing Azure Container Instance, delete it now

```sh
az container delete -g akschallenge -n loadtest
```

Running the load test again

```sh
az container create -g akschallenge -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_IP=<public ip of order capture service>
```

Observe your Kubernetes cluster reacting to the load by running

```sh
kubectl get pods -l
```

<video width="100%" controls>
  <source src="media/autoscale-in-action.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>

{% endcollapsible %}

#### Deploy MongoDB as a StatefulSet

Now that you scaled the replicas running the API, maybe it is time to scale MongoDB? If you used the typical command to deploy MongoDB using Helm, most likely you deployed a single instance of MongoDB running in a single container. For this section, you'll redeploy the chart with "replicaSet" enabled.

The authors of the MongoDB chart created it so that it supports deploying a MongoDB replica set through the use of Kubernetes StatefulSet for the secondary replica set. A replica set in MongoDB provides redundancy and high availability and in some cases, increased read capacity as clients can send read operations to different servers.

{% collapsible %}

Upgrade the MongoDB Helm release to use replication

```sh
helm upgrade orders-mongo stable/mongodb --set replicaSet.enabled=true,mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

Verify how many secondaries are running

```sh
kubectl get pods -l app=mongodb
```

You should get a result similar to the below

```sh
NAME                               READY   STATUS    RESTARTS   AGE
orders-mongo-mongodb-arbiter-0     1/1     Running   1          3m
orders-mongo-mongodb-primary-0     1/1     Running   0          2m
orders-mongo-mongodb-secondary-0   1/1     Running   0          3m
```

Now scale the secondaries using the command below.

```sh
kubectl scale statefulset orders-mongo-mongodb-secondary --replicas=3
```

You should now end up with 3 MongoDB secondary replicas similar to the below

```sh
NAME                               READY   STATUS              RESTARTS   AGE
orders-mongo-mongodb-arbiter-0     1/1     Running             3          8m
orders-mongo-mongodb-primary-0     1/1     Running             0          7m
orders-mongo-mongodb-secondary-0   1/1     Running             0          8m
orders-mongo-mongodb-secondary-1   0/1     Running             0          58s
orders-mongo-mongodb-secondary-2   0/1     Running             0          58s
```

{% endcollapsible %}

#### Check if your cluster nodes needs to scale/auto-scale

{% collapsible %}

Scale the cluster nodes using the command below to the required number of nodes

```sh
az aks scale --resource-group akschallenge --name <unique-aks-cluster-name> --node-count 4
```

You can also optionally configure the AKS cluster-autoscaler <https://docs.microsoft.com/en-us/azure/aks/autoscaler>.

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale>
> * <https://docs.microsoft.com/en-us/azure/aks/autoscaler>
> * <https://docs.microsoft.com/en-gb/vsts/load-test/get-started-simple-cloud-load-test>