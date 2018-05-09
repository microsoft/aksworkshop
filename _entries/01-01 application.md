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

**Order Capture API**
- Docker Image: <https://hub.docker.com/r/shanepeckham/captureorderack/>
- GitHub Repo: <https://github.com/shanepeckham/captureorderack/>

Required Environment Variables:

*Challenge Logging*

ENV TEAMNAME=[YourTeamName]

*Mongo*

ENV MONGOHOST="mongodb://[mongoinstance].[namespace]"

*RabbitMQ*

ENV RABBITMQHOST=amqp://[url]:5672

**Event Listener**
- Docker Image: <https://hub.docker.com/r/shanepeckham/rabbitmqlistenerack/>
- GitHub Repo: <https://github.com/shanepeckham/rabbitmqlistenerack/> 

Required Environment Variables:

*Challenge Logging*

ENV TEAMNAME= Your team name

*RabbitMQ*

ENV RABBITMQHOST=amqp://[url]:5672
ENV PARTITIONKEY=[0,1,2] ** If you want to use partitions specify a number on your listener

*Internal Fulfill order endpoint*

ENV PROCESSENDPOINT=http://[yourfulfillordername].[namespace]:8080/v1/order

**Order Fulfill API**
- Docker Image: <https://hub.docker.com/r/shanepeckham/fulfillorderack/>
- GitHub Repo: <https://github.com/shanepeckham/fulfillorderack/>

Required Environment Variables:

*ACK Logging*

ENV TEAMNAME=[YourTeamName]

*For Mongo*

ENV MONGOHOST="mongodb://[mongoinstance].[namespace]"

*Order Storage Location*

/orders
