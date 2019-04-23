---
sectionid: scoring
sectionclass: h2
title: Scoring
parent-id: intro
---

To add an element of competitiveness to the workshop your solutions may be evaluated using both remote monitoring and objective assessments.

<!--
### Availability

Application uptime over period of the workshop. We will be continuously making HTTP requests to your API.
Availability monitoring using Azure Application Insights (<https://docs.microsoft.com/en-us/azure/azure-monitor/app/monitor-web-app-availability>) will be used.

> **Note** Provide your proctor with the public endpoint of your `captureorder` service. The proctor will setup [URL ping tests using Azure Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-monitor-web-app-availability) to each team's swagger endpoint, typically this would be something like `http://<public endpoint>/swagger/`.
-->


Try to maximize the number of successful requests (orders) processed per second submitted to the capture order endpoint (`http://<your endpoint>:80/v1/order/`).

Refer to the [scaling section for guidance on how to run the load test](#scaling).

### Teamwork

Ideally, you should work in teams. You should have been provided a team name. If not, come up with a unique name and make sure to set it in the environment variable `TEAMNAME` to be able to properly track your progress.