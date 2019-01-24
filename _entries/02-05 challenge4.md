---
sectionid: scaling
sectionclass: h2
parent-id: upandrunning
title: Scaling
---

As popularity of the application grows the application needs to scale appropriately as demand changes.
Ensure the application remains responsive as the number of order submissions increases.

### Tasks

#### Create Horizontal Pod Autoscaler

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

#### Run a load test using Azure Container Instances

{% collapsible %}
There is a a container image on Docker Hub ([azch/loadtest](https://hub.docker.com/r/azch/loadtest)) that is preconfigured to run the load test. You may run it in [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) running the command below

```sh
az container create -g akschallenge --n loadtest --image azch/loadtest -e SERVICE_IP=<public ip of order capture service> --restart-policy Never --no-wait
```

This will fire off a series of increasing loads of concurrent users (100, 200, 400, 800, 1600) POSTing requests to your Order Capture API endpoint with some wait time in between to simulate an increased pressure on your application.

You may attach to the Azure Container Instance streaming logs by running the command below

```sh
az container attach -g akschallenge --n loadtest
```

Make note of results (sample below) for each of the load tests to figure out where you need to optimize to increase the throughtput (requests/sec), reduce the average latency and error count.

```
Phase 3: Load test - 30 seconds, 400 users.

Summary:
  Total:        30.9292 secs
  Slowest:      19.9250 secs
  Fastest:      0.0015 secs
  Average:      0.1683 secs
  Requests/sec: 2310.5693
  
  Total data:   3072866 bytes
  Size/request: 43 bytes

Response time histogram:
  0.002 [1]     |
  1.994 [70584] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  3.986 [558]   |
  5.979 [119]   |
  7.971 [98]    |
  9.963 [46]    |
  11.956 [23]   |
  13.948 [17]   |
  15.940 [11]   |
  17.933 [2]    |
  19.925 [3]    |


Latency distribution:
  10% in 0.0035 secs
  25% in 0.0078 secs
  50% in 0.0343 secs
  75% in 0.1093 secs
  90% in 0.3231 secs
  95% in 0.6346 secs
  99% in 2.2680 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0002 secs, 0.0015 secs, 19.9250 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:    0.0000 secs, 0.0000 secs, 0.0143 secs
  resp wait:    0.1680 secs, 0.0014 secs, 19.9249 secs
  resp read:    0.0000 secs, 0.0000 secs, 0.0056 secs

Status code distribution:
  [200] 71462 responses

Error distribution:
  [2]   Post http://23.96.91.35/v1/order: net/http: request canceled (Client.Timeout exceeded while awaiting headers)
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

#### Scale MongoDB

{% collapsible %}

If you used the replicated MongoDB Helm chart, you can scale the secondaries using the command below.

```sh
kubectl scale statefulset orders-mongo-mongodb-secondary --replicas=3
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