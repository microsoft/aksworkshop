---
sectionid: monitoring
sectionclass: h2
parent-id: upandrunning
title: Monitoring
---

You would like to monitor the performance of different components in your application, view logs and get alerts whenever your application availability goes down or some components fail.

Use a combination of the available tools to setup alerting capabilities for your application.

### Tasks

#### Instrument the application with Azure Application Insights to track how requests move within the application

> **Hint** The application compoments are provisioned to send telemetry to Azure Application Insights. You can create your own Azure Application Insights service and provide the instrumentation key as an environment variable named `APPINSIGHTS_KEY`.

{% collapsible %}

- Create a new Application Insights resource <https://docs.microsoft.com/en-us/azure/application-insights/app-insights-create-new-resource>
- Provide the instrumentation key as an environment variable named `APPINSIGHTS_KEY` to all deployments.
- View how your application is performing on the Application Map
  ![Application map](media/applicationmap.png)

{% endcollapsible %}

#### Leverage integrated Azure Kubernetes Service monitoring to figure out why requests are failing, inspect logs and monitor your cluster health

{% collapsible %}

- Check the cluster utilization under load
  ![Cluster utilization](media/clusterutilization.png)

- Identify which pods are causing trouble
  ![Pod utilization](media/podmetrics.png)
  
{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/application-insights/app-insights-alerts?wt.mc_id=CSE_(606698)>
> * <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview>
> * <https://coreos.com/operators/prometheus/docs/latest/>