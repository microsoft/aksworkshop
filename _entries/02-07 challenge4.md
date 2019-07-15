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
az container create -g <resource-group> -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_IP=<public ip of order capture service>
```

This will fire off a series of increasing loads of concurrent users (100, 400, 1600, 3200, 6400) POSTing requests to your Order Capture API endpoint with some wait time in between to simulate an increased pressure on your application.

You may view the logs of the Azure Container Instance streaming logs by running the command below. You may need to wait for a few minutes to get the full logs, or run this command multiple times.

```sh
az container logs -g <resource-group> -n loadtest
```

When you're done, you may delete it by running

```sh
az container delete -g <resource-group> -n loadtest
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
az container delete -g <resource-group> -n loadtest
```

Running the load test again

```sh
az container create -g <resource-group> -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_IP=<public ip of order capture service>
```

Observe your Kubernetes cluster reacting to the load by running

```sh
kubectl get pods -l  app=captureorder
```

<video width="100%" controls>
  <source src="media/autoscale-in-action.mp4" type="video/mp4">
Your browser does not support the video tag.
</video>

{% endcollapsible %}

#### Check if your cluster nodes needs to scale/autoscale

{% collapsible %}

If your AKS cluster is not configured with the cluster autoscaler, scale the cluster nodes using the command below to the required number of nodes

```sh
az aks scale --resource-group <resource-group> --name <unique-aks-cluster-name> --node-count 4
```

Otherwise, if you configured your AKS cluster with cluster autoscaler, you should see it dynamically adding and removing nodes based on the cluster utilization. To change the node count, use the `az aks update` command and specify a minimum and maximum value. The following example sets the `--min-count` to *1* and the `--max-count` to *5*:

```sh
az aks update \
  --resource-group <resource-group> \
  --name <unique-aks-cluster-name> \
  --update-cluster-autoscaler \
  --min-count 1 \
  --max-count 5
```

> **Note** During preview, you can't set a higher minimum node count than is currently set for the cluster. For example, if you currently have min count set to *1*, you can't update the min count to *3*.

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale>
> * <https://docs.microsoft.com/en-us/azure/aks/autoscaler>