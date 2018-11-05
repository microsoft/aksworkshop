---
sectionid: sbqueue
sectionclass: h2
parent-id: enhancing
title: Swap out Rabbit MQ for Azure Service Bus Queues

---
Your organisation has decided it wants to reduce the management overhead and
improve the availability of the Order Capture process by utilising a native Azure
Service Bus Queue. Replace the Eventlistener RabbitMQ container with a prebuilt Azure
Service Bus Queue listener container with zero downtime.

* For the Service Bus Queue container, refer to the following:
- Docker Image and imformation on environment variables - <https://hub.docker.com/r/torosent/sbqueuelistenerack/>
- Git hub repo - <https://github.com/torosent/sbqueuelistenerack/> 

![](media/25a643873acbb18166772fc1ac25b15d.png)