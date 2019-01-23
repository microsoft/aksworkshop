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

#### Run a load test

{% collapsible %}

You can run the script below to send off a number of POST requests and get the results.

> **Note**
> * You'll need to run this on your local machine from a *nix (bash, zsh, etc.) shell. It will not work on Azure Cloud Shell. You will need to have Docker installed and running in order to use this script.
> * You may tweak it after downloading to your liking.
> * Just as with any script, we recommend reading the script thoroughly prior to running it on your machine.
> * The Horizontal Pod Autoscaler (HPA) has a default cooldown period of 5 minutes, so keep this into consideration when you're doing the tests.

```sh
wget http://aka.ms/aks/workshop/loadtest.sh
chmod +x loadtest.sh
./loadtest.sh <public ip of the capture order service>
```

You should see an experience similar to the below:

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