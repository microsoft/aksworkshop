---
sectionid: eventhubs
sectionclass: h2
parent-id: enhancing
title: Swap out Rabbit MQ for Event Hubs

---
Your organisation has decided it wants to reduce the management overhead and
improve the availability of the Order Capture process by utilising a native Azure
event hub. Replace the Eventlistener RabbitMQ container with a prebuilt Azure
Event Hub listener container with zero downtime.

* For the Event Hub container, refer to the following:
- Docker Image and imformation on environment variables - <https://hub.docker.com/r/shanepeckham/eventhublistenerack/>
- Git hub repo - <https://github.com/shanepeckham/eventhublistenerack/tree/v3> **Note we are using branch v5**

Azure Event Hubs enables you to use an event driven approach to incorporate first
party Azure services.

![](media/25a643873acbb18166772fc1ac25b15d.png)