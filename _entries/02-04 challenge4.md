---
sectionclass: h2
sectionid: monitoring
parent-id: upandrunning
title: Monitoring
---

You need to have deep insights into the current status of your application and
the Kubernetes infrastructure.

1.Implement a monitoring solution of your choice. Resources (suggestions, there are many others you may prefer to use):

- Grafana and Prometheus. To access Grafana dashboard, change the service type to LoadBalancer or use port-forward
    <https://github.com/coreos/prometheus-operator/tree/master/helm>

- CoScale:
    - <https://app.coscale.com/app/register/> - select AKS
    - <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-coscale?wt.mc_id=CSE_(606698)>

- Datadog:
    <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-datadog?wt.mc_id=CSE_(606698)>

- Sysdig:
    <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-sysdig?wt.mc_id=CSE_(606698)>

- OMS (currently a delay for data to initially appear):
    <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-oms?wt.mc_id=CSE_(606698)>
    <https://kubeapps.com/charts/stable/msoms>

2. Configure your application to work with [Azure Application Insights](https://docs.microsoft.com/en-us/azure/application-insights/app-insights-overview?wt.mc_id=CSE_(606698)). You can provision your own Azure Application Insights instance and supply the key in the environment variables.