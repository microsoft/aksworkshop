---
sectionid:  orderfulfilment
sectionclass: h2
title: Implementing order fulfilment
parent-id: upandrunning
---


The Order Fulfilment process needs to be deployed. This includes an event hub to broker messages and the Order Fulfilment service.

You need to implement RabbitMQ so that our Order Capture API can drop orders on to it. You will also need to implement the Eventlistener container so that it
can efficiently process messages from the Capture Order API.

The fulfillorder container must be deployed as an internal only API. This container will fulfill orders and output orders for future batch processing. The
order transaction files from all instances of order fulfillment must be written to a single location that also enables staff to inspect the log files without interacting
with Kubernetes.

![](/media/91e5586b630e88d67ecd28bc42ae92b2.png)

1.  Deploy Rabbit MQ

2.  Configure captureorder to connect to RabbitMQ. Authentication needs to be configured to connect successfully.

3.  Provision Order Fulfillment and event listener containers. **Ensure you are using the most recent version of the image**

4.  Configure Order Fulfillment to store data to Azure Files

**Resources:**

-   <https://kubeapps.com/charts/stable/rabbitmq>

-   <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>

- <https://docs.microsoft.com/gl-es/azure/aks/azure-files-dynamic-pv?wt.mc_id=CSE_(606698)>

-   <https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-file>



