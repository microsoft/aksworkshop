---
sectionid: scoring
sectionclass: h2
title: Scoring
parent-id: intro
---

To add an element of competitiveness to the workshop your solutions will be evaluated using both remote monitoring and objective assessments. At the end of the workshop we will announce a winner. You will be scored under the following areas:

### Availability

Application uptime over period of the workshop. We will be continuously making HTTP requests to your API.
Availability monitoring using Azure Application Insights (<https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability>) will be used.

> **Note** Provide your proctor with the public endpoint of your `captureorder` service. The proctor will setup [URL ping tests using Azure Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-monitor-web-app-availability) to each team's swagger endpoint, typically this would be something like `http://<public endpoint>/swagger/`.

### Throughput

Ability to cope with periodic load tests, through the maximum number of successful requests per second. These will be order submissions to `http://<your endpoint>:80/v1/order/`. We will be directing up to 6400 concurrent users to your application.

Refer to the [scaling section for guidance on how to run the load test](#scaling).

### Extra tasks

There will be a list of extra tasks, intermediate and advanced level. Each task, successfully accomplished, counts for extra bonus points.

### Team

You should have been provided a team name. If not, come up with a unique name and make sure to set it in the environment variables to be able to properly track your progress.