---
layout: page
title: Introduction
---

# Application Overview

You will be deploying a customer facing order placement and fulfilment application that is containerised and is architected for a microservice implementation.

![](media/302a7509f056cd57093c7a3de32dbb04.png)

Source Repository: <http://github.com/XXX>

The order capture API is available via swagger at http://hmm\<capture\_order\_endpoint\>:8080/swagger/

Initial versions of the Docker containers have been provided by the development team and are available at in the repo: http://hub.docker.com/...:

# Hack Scoring

We will evaluate solutions using both remote monitoring and objective assessments and score the following areas:

## Availability

Application uptime over period of the hack. We will be continuously making HTTP requests to your API.

## Throughput

Ability to cope with periodic load tests. These will be order submissions to http://\<your endpoint\>:8080/v1/order/. We will be directing up to 2000 users to your application.

## DevOps

Ease of enabling an application code change to get to production and ability to maintain a production service.

## Innovation

Use of novel solutions to complete challenges in an innovative way

## Fault Tolerance

Ability to withstand both application and infrastructure failure

## Security

Quality of monitoring and consideration given to security

## Cost management

Amount spent and the steps taken to reduce Azure consumption

# Challenges

The challenges are intended to be a challenge! Useful resources are provided to help you work through each challenge but step by step instructions are not provided. If you feel you need assistance, please ask your proctor.

Proceed to [Challenge 1](./challenges/challenge1.html)