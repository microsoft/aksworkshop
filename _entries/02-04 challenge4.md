---
sectionclass: h2
sectionid: monitoring
parent-id: upandrunning
title: Monitoring
---

You need to have deep insights into the current status of your application and
the Kubernetes infrastructure.

1. Implement a monitoring solution of your choice. Resources (suggestions, there are many others you may prefer to use):
    * **Azure Monitor** <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview?wt.mc_id=CSE_(606698)>
    * **Grafana and Prometheus** <https://github.com/coreos/prometheus-operator/tree/master/helm>
    * **CoScale** <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-coscale?wt.mc_id=CSE_(606698)>
    * **Datadog** <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-datadog?wt.mc_id=CSE_(606698)>
    * **Sysdig** <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-sysdig?wt.mc_id=CSE_(606698)>

1. Configure your application to work with [Azure Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-overview?wt.mc_id=CSE_(606698)). You can provision your own Azure Application Insights instance and supply the key in the environment variable `APPINSIGHTS_KEY`.