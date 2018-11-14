---
sectionid:  orderfulfilment
sectionclass: h2
title: Deploy the Order Fulfilment components
parent-id: upandrunning
---

The Order Fulfilment process needs to be deployed. This includes:

* An **messaging bus** to broker messages. The application is configured to use [Azure Service Bus Queues](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-queues-topics-subscriptions) as the message bus. You'll need to provision this and configure the application accordingly.
* An **event processor** ([azch/sblistener](https://hub.docker.com/r/azch/sblistener/)). This process listens to messages coming to the Service Bus Queues.
* The **order fulfillment service** ([azch/fulfillorder](https://hub.docker.com/r/azch/fulfillorder/)). This container will fulfill orders and output orders for future batch processing. The order transaction files from all instances of order fulfillment must be written to a single location that also enables staff to inspect the log files without interacting with Kubernetes.

![Application components](/media/fulfillorder.png)

> **Hint** Refer to the [container images and source code](#container-images-and-source-code) and [environment variables](#environment-variables) sections to properly configure the application.

### Tasks

1. Create an Azure Service Bus Queue
1. Configure `captureorder` to connect to the Azure Service Bus Queue
1. Provision `fulfillorder` deployment, it **should not** be exposed to the internet
1. Provision `sblistener` deployment
1. Configure `fulfillorder` to store data to Azure Files. You need to write files in the `/orders` path
1. Verify that the orders are written in the Azure File Share

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues>
> * <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>
> * <https://docs.microsoft.com/gl-es/azure/aks/azure-files-dynamic-pv?wt.mc_id=CSE_(606698)>
> * <https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-file>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>