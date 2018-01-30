---
sectionid: scaling
sectionclass: h2
parent-id: enhancing
title: Scaling
---

As popularity of the application grows the application needs to scale
appropriately as demand changes. Ensure the application remains responsive as
the number of order submissions increases. Please be aware that adding additional nodes will consume additional credit.

Note, the Eventlistener does not utilise a pub/sub, competing consumers or
routing pattern, it simply drops a message on a unique queue. This means that
you cannot have more than one eventlistener instance listening to a specific
queue.

1.  Configure the Capture Order process to scale as load increases

2.  Ensure Capture Order can sustain the required load.

3.  Scale other parts of the application as required.

Resources:

-   <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/>

-   <https://docs.microsoft.com/en-gb/vsts/load-test/get-started-simple-cloud-load-test>