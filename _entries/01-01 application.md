---

sectionclass: h2
title: Application Overview
parent-id: intro
---

You will be deploying a customer-facing order placement and fulfilment application that is containerised and is architected for a microservice implementation.

![Application diagram](media/302a7509f056cd57093c7a3de32dbb04.png)

The application consists of 5 components, namely:

* A public facing Order Capture swagger enabled API
* A messaging queue to provide reliable message delivery
* An event listener that picks up events from the messaging queue and brokers requests to a 'legacy application'
* An internal Order Fulfill legacy API.
* A MongoDB database

> **Hint:** The Order Capture API exposes the following endpoint for health-checks: `http://[PublicEndpoint]:[port]/healthz`

In the table below, you will find the Docker container images provided by the development team on Docker Hub as well as their corresponding source code on GitHub.

### Container images and source code

| Component                    | Docker Image                                                     | Source Code                                                       | Build Status |
|------------------------------|------------------------------------------------------------------|-------------------------------------------------------------------|--------------|
| Order Capture API            | [azch/captureorder](https://hub.docker.com/r/azch/captureorder/) | [source-code](https://github.com/Azure/azch-captureorder)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-captureorder)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=10) |
| Order Fulfillment API        | [azch/fulfillorder](https://hub.docker.com/r/azch/fulfillorder/) | [source-code](https://github.com/Azure/azch-fulfillorder)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-fulfillorder)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=11) |
| Event Listener (RabbitMQ)    | [azch/rabbitmqlistener](https://hub.docker.com/r/azch/rabbitmqlistener/) | [source-code](https://github.com/Azure/azch-rabbitmqlistener)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-rabbitmqlistener)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=12) |
| Event Listener (Event Hub)    | [azch/eventhublistener](https://hub.docker.com/r/azch/eventhublistener/) | [source-code](https://github.com/Azure/azch-eventhublistener)         | [![Build Status](https://dev.azure.com/theazurechallenge/Kubernetes/_apis/build/status/Code/Azure.azch-eventhublistener)](https://dev.azure.com/theazurechallenge/Kubernetes/_build/latest?definitionId=13) |

> **Hint:** You will not be using all container images at the same time.

### Environment variables

Each container image requires certain environment variables to properly run and track your progress.

Make sure you set those environment variables.

* **All Containers**
  * `TEAMNAME="[YourTeamName]"`
    * Track your team's progress. Use your assigned team name
  * `CHALLENGEAPPINSIGHTS_KEY="[AsSpecifiedAtTheEvent]"`
    * Application Insights key provided by proctors
  * `APPINSIGHTS_KEY="[YourOwnKey]"`
    * Your own Application Insights key, if you want to track application metrics
* **Order Capture API**
  * `MONGOURL="mongodb://[mongoinstance].[namespace]"`
    * MongoDB connection endpoint. Don't forget to set the username/password
  * `AMQPURL="amqp://[url]:5672"`
    * RabbitMQ connection endpoint
  * `AMQPURL="amqps://[policy name]:[policy key]@[youreventhub].servicebus.windows.net/[eventhubname]`"
    * Azure Event Hub connection endpoint. **Make sure your policy key is URL Encoded. Use a tool like: <https://www.url-encode-decode.com/>**
* **Order Fulfillment API**
  * `MONGOURL="mongodb://[mongoinstance].[namespace]"`
    * MongoDB connection endpoint. Don't forget to set the username/password
* **Event Listener (RabbitMQ)**
  * `AMQPURL="amqp://[url]:5672"`
    * RabbitMQ connection endpoint
  * `PROCESSENDPOINT="http://[yourfulfillordername].[namespace]:8080/v1/order"`
    * Order Fulfillment API endpoint
* **Event Listener (Event Hub)**
  * `EVENTHUBCONNSTRING="Endpoint=sb://[youreventhub].servicebus.windows.net/;SharedAccessKeyName=[keyname];SharedAccessKey=[key]"`
    * Azure Event Hub connection endpoint. **Make sure your policy key is URL Encoded. Use a tool like: <https://www.url-encode-decode.com/>**
  * `PROCESSENDPOINT="http://[yourfulfillordername].[namespace]:8080/v1/order"`
    * Order Fulfillment API endpoint.