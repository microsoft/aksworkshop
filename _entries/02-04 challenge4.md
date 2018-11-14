---
sectionid: monitoring
sectionclass: h2
parent-id: upandrunning
title: Monitoring
---

You would like to monitor the performance of different components in your application, view logs and get alerts whenever your application availability goes down or some components fail.

Use a combination of the available tools to setup alerting capabilities for your application.

### Tasks

1. Instrument the application with Azure Application Insights to track how requests move within the application

    > **Hint** The application compoments are provisioned to send telemetry to Azure Application Insights. You can create your own Azure Application Insights service and provide the instrumentation key as an environment variable named `APPINSIGHTS_KEY`.

1. Leverage integrated Azure Kubernetes Service monitoring to figure out why requests are failing, inspect logs and monitor your cluster health

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/application-insights/app-insights-alerts?wt.mc_id=CSE_(606698)>
> * <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview>
> * <https://coreos.com/operators/prometheus/docs/latest/>