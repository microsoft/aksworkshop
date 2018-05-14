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
* An event listener that picks up events from the messaging queue and brokers requests to a 'legacy application'
* An internal Order Fulfill legacy API.
* A MongoDB database

The order capture API is available at  http://[PublicEndpoint]:[port]/v1/order, and via swagger at http://[PublicEndpoint]:[port]/swagger/.

Initial versions of the Docker containers have been provided by the development team and are available on Docker Hub at the locations specified. 
