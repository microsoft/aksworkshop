---
sectionid: scaling
sectionclass: h2
parent-id: upandrunning
title: Scaling
---

As popularity of the application grows the application needs to scale appropriately as demand changes. 
Ensure the application remains responsive as the number of order submissions increases. Consider the cost impact of scaling your infrastructure.

Note, the Eventlistener utilises a competing/compensating consumers routing pattern. This means that you can have more than one eventlistener instance listening to a specific
queue. Try using partitions.

1.  Configure the Capture Order process to scale as load increases

2.  Ensure Capture Order can sustain the required load.

3.  Scale other parts of the application as required.

**Resources:**

-   <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>

-   <https://docs.microsoft.com/en-gb/vsts/load-test/get-started-simple-cloud-load-test?wt.mc_id=CSE_(606698)>