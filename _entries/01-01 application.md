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
* A MongoDB database

The order capture API is available via swagger at http://<PublicEndpoint>:8080/swagger/

Initial versions of the Docker containers have been provided by the development team and are available at in the repo: 

**Order Capture API**
- Docker Image: <https://hub.docker.com/r/shanepeckham/captureorderack/>
- GitHub Repo: <https://github.com/shanepeckham/captureorderack/tree/v5> ***Note we are using branch v5

Required Environment Variables:

*Challenge Logging*

ENV TEAMNAME=[YourTeamName]

*Mongo*

ENV MONGOHOST="mongodb://[mongoinstance]"

*RabbitMQ*

ENV RABBITMQHOST=amqp://[url]:5672

**Event Listener**
- Docker Image: <https://hub.docker.com/r/shanepeckham/rabbitmqlistenerack/>
- GitHub Repo: <https://github.com/shanepeckham/rabbitmqlistenerack/tree/v5> ***Note we are using branch v5

Required Environment Variables:

*Challenge Logging*

ENV TEAMNAME= Your team name

*RabbitMQ*

ENV RABBITMQHOST=amqp://[url]:5672

*Internal Fulfill order endpoint*

ENV PROCESSENDPOINT=http://[yourfulfillordername]:8080/v1/order

**Order Fulfill API**
- Docker Image: <https://hub.docker.com/r/shanepeckham/fulfillorderack/>
- GitHub Repo: <https://github.com/shanepeckham/fulfillorderack/tree/v5> ***Note we are using branch v5

Required Environment Variables:

*ACK Logging*

ENV TEAMNAME=[YourTeamName]

*For Mongo*

ENV MONGOHOST="mongodb://[mongoinstance]"

*Order Storage Location*

/orders
