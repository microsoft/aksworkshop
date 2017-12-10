---

sectionclass: h2
title: Application Overview
parent-id: intro
---


You will be deploying a customer-facing order placement and fulfilment application that is containerised and is architected for a microservice implementation.

![](media/302a7509f056cd57093c7a3de32dbb04.png)

Our application consists of 5 components, namely: 
* A public facing Order Capture swagger enabled API
* A messaging queue to provide reliable message delivery
* An event listener that picks up events from the messaging queue and brokers requests
* An internal Order Fulfill API.

The order capture API is available via swagger at http://<PublicEndpoint>:8080/swagger/

Initial versions of the Docker containers have been provided by the development team and are available at in the repo: 

* Order Capture API
- Docker Image and imformation on environment variables -  <https://hub.docker.com/r/shanepeckham/captureorderack/>
- Git hub repo - <https://github.com/shanepeckham/captureorderack/tree/v3> ***Note we are using branch v3

* Event Listener 
- Docker Image and imformation on environment variables - <https://hub.docker.com/r/shanepeckham/rabbitmqlistenerack/>
- Git hub repo - <https://github.com/shanepeckham/rabbitmqlistenerack/tree/v3> ***Note we are using branch v3

* Order Fulfill API
- Docker Image and imformation on environment variables - <https://hub.docker.com/r/shanepeckham/fulfillorderack/>
- Git hub repo - <https://github.com/shanepeckham/fulfillorderack/tree/v3> ***Note we are using branch v3
