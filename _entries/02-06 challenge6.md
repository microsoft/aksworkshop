---
sectionid: eventhubs
sectionclass: h2
parent-id: upandrunning
title: Swap out Rabbit MQ for Event Hubs

---
Your organisation has decided it wants to reduce the management overhead and improve the availability of the Order Capture process by utilising a native Azure Event Hub.

![Application components](media/25a643873acbb18166772fc1ac25b15d.png)

### Tasks

- Replace the Eventlistener RabbitMQ container with a prebuilt Azure Event Hub listener container with zero downtime.

> **Hint** Refer to the [container images and source code](#container-images-and-source-code) and [environment variables](#environment-variables) sections to use the correct images and configuration.

Azure Event Hubs enables you to use an event driven approach to incorporate first party Azure services. Pay attention to how you can tune the throughout of EventHubs.