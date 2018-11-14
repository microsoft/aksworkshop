---
sectionid: scaling
sectionclass: h2
parent-id: upandrunning
title: Scaling
---

As popularity of the application grows the application needs to scale appropriately as demand changes.
Ensure the application remains responsive as the number of order submissions increases. Consider the cost impact of scaling your infrastructure.

> **Hint** The `eventlistener` utilises a competing/compensating consumers routing pattern. This means that you can have more than one eventlistener instance listening to a specific queue.
> Also make sure as you increase the number of replicas that your cluster has enough capacity to handle this load.

### Tasks

1. Configure the `captureorder` and `fulfillorder` to scale as load increases
1. Scale up the number of `eventlistener` replicas
1. Check if your cluster nodes needs to scale/auto-scale
1. Scale other parts of the application as required

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale>
> * <https://docs.microsoft.com/en-us/azure/aks/autoscaler>
> * <https://docs.microsoft.com/en-gb/vsts/load-test/get-started-simple-cloud-load-test?wt.mc_id=CSE_(433127)>