---
sectionid: scaling
sectionclass: h2
parent-id: upandrunning
title: Scaling
---

As the popularity of the application grows, the application needs to scale appropriately as demand changes.
Ensure the application remains responsive as the number of order submissions increases.

### Tasks

#### Run a baseline load test

**Task Hints**
* A pre-built image on Dockerhub has been created called `azch/loadtest`, this uses a tool called 'hey' to inject a large amount of traffic to the capture order API
* [Azure Container Instances](https://docs.microsoft.com/en-gb/azure/container-instances/) can be used to run this image as a container, e.g using the  `az container create` command.
* When running as a Container Instance set we don't want it to restart once it has finished, so set `--restart-policy Never` 
* Provide the endpoint of your capture orders service in `SERVICE_ENDPOINT` environmental variable e.g. `-e SERVICE_ENDPOINT=https://orders.{ingress-ip}.nip.io`
* You can watch the orders come in using the Frontend application, and can view the detailed output of the load test with the `az container logs` command
* Make a note of the results, response times etc

{% collapsible %}

There is a container image on Docker Hub ([azch/loadtest](https://hub.docker.com/r/azch/loadtest)) that is preconfigured to run the load test. You may run it in [Azure Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) running the command below

```sh
az container create -g <resource-group> -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_ENDPOINT=https://<hostname order capture service>
```

This will fire off a series of increasing loads of concurrent users (100, 400, 1600, 3200, 6400) POSTing requests to your Order Capture API endpoint with some wait time in between to simulate an increased pressure on your application.

You may view the logs of the Azure Container Instance by running the command below. 

```sh
az container logs -g <resource-group> -n loadtest --follow
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

Most likely in your initial test, the `captureorder` container was the bottleneck. So the first step would be to scale it out. There are two ways to do so

* You can manually increase the number of replicas in the deployment by using the `kubectl scale` command or by editing the deployment's YAML file
* You can use the Horizontal Pod Autoscaler (HPA) to automatically adjust the number of replicas based on demand

Horizontal Pod Autoscaler allows Kubernetes to detect when your deployed pods need more resources and then it schedules more pods onto the cluster to cope with the demand.

**Task Hints**
* The [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale) (HPA) is a way for deployments to scale their pods out automatically based on metrics such as CPU utilization. 
* There are two versions of the HPA object - `autoscaling/v1` and `autoscaling/v2beta2`. The `v2beta2` adds support for multiple metrics, custom metrics and other features. For this workshop though, the capabilities of the `v1` version are sufficient.
* The `kubectl autoscale` command can easily set up a HPA for any deployment, [this walkthrough guide has an example you can re-use.](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#create-horizontal-pod-autoscaler)
* Alternatively you can define the HPA object in a YAML file.
* For the HPA to work, you must add [resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) to your captureorder deployment, if you haven't already done so. Good values to use are `cpu: "500m"` (which is equivalent to half a CPU core), and for memory specify `memory: "256Mi"`.
* Validate the HPA with `kubectl get hpa` and make sure the `Targets` column is not showing `<unknown>` 

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
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

And deploy it using

```sh
kubectl apply -f captureorder-hpa.yaml
```

> **Important** For the Horizontal Pod Autoscaler to work, you **MUST** define requests and limits in the Capture Order API's deployment.
{% endcollapsible %}

#### Run a load test again after applying Horizontal Pod Autoscaler

**Task Hints**
* Delete your load test container instance (`az container delete`) and re-create it to run another test, with the same parameters as before
* Watch the behavior of the HPA with `kubectl get hpa` and use `kubectl get pod` to see the new captureorder pods start, when auto-scaling triggers more replicas
* Observe the change in load test results
  
{% collapsible %}

If you didn't delete the load testing Azure Container Instance, delete it now

```sh
az container delete -g <resource-group> -n loadtest
```

Running the load test again

```sh
az container create -g <resource-group> -n loadtest --image azch/loadtest --restart-policy Never -e SERVICE_ENDPOINT=https://<hostname order capture service>
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

**Task Hints**
* As the HPA scales out with more & more pods, eventually the cluster will run out of resources. You will see pods in pending state.
* You can use the `kubectl describe hpa <hpa-name>` command to see more information about what the HPA is doing and when it triggers the deployment of additional pods or removal of surplus pods
* You can use the `kubectl top` command to view the CPU and memory utilisation of `pods` and `nodes`. This will tell you whether the cluster is hitting CPU and memory limits and should therefore need to scale. 
* You may have to artificially force this situation by increasing the resource `request` and `limit` for memory in the captureorder deployment to `memory: "4G"` or even `memory: "2G"` (and re-deploy/apply the deployment)
* If you enabled the cluster autoscaler, you might be able to get the cluster to scale automatically, check the node count with `kubectl get nodes`.
* If you didn't enable the autoscaler you can try manually scaling with the `az aks scale` command and the `--node-count` parameter
  
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

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale>
> * <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale>
> * <https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container>
> * <https://docs.microsoft.com/en-us/azure/aks/autoscaler>
