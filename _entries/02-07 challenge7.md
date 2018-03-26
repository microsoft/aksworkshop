---
sectionid: eventhubs
sectionclass: h2
parent-id: upandrunning
title: Swap out Rabbit MQ for Event Hubs

---
Your organisation has decided it wants to reduce the management overhead and improve the availability of the Order Capture process by utilising a native Azure
event hub. 
Replace the Eventlistener RabbitMQ container with a prebuilt Azure Event Hub listener container with zero downtime.

*  For the OrderCapture API, refer to the following:
-  Docker Image and information on environment variables - <https://hub.docker.com/r/sabbour/captureorderack/>
- Git hub repo - <https://github.com/sabbour/captureorderack/tree/master/netcore>

* For the Event Hub container, refer to the following:
- Docker Image and information on environment variables - <https://hub.docker.com/r/sabbour/eventhublistenerack/>
- Git hub repo - <https://github.com/sabbour/eventhublistenerack/> 

Azure Event Hubs enables you to use an event driven approach to incorporate first party Azure services. Pay attention to how you can tune the throughout of EventHubs.

![](media/25a643873acbb18166772fc1ac25b15d.png)