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

#### View the live container logs

{% collapsible %}

If the cluster is RBAC enabled, you have to create the appropriate `ClusterRole` and `ClusterRoleBinding`.

Save the YAML below as `logreader-rbac.yaml` or download it from [logreader-rbac.yaml](yaml-solutions/01. challenge-03/logreader-rbac.yaml)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
   name: containerHealth-log-reader
rules:
   - apiGroups: [""]
     resources: ["pods/log"]
     verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
   name: containerHealth-read-logs-global
roleRef:
  kind: ClusterRole
  name: containerHealth-log-reader
  apiGroup: rbac.authorization.k8s.io
subjects:
   - kind: User
     name: clusterUser
     apiGroup: rbac.authorization.k8s.io
```

And deploy it using

```sh
kubectl apply -f logreader-rbac.yaml
```

If you have a Kubernetes cluster that is not configured with Kubernetes RBAC authorization or integrated with Azure AD single-sign on, you do not need to follow the steps above. Because Kubernetes authorization uses the kube-api, read-only permissions is required.

Head over to the AKS cluster on the Azure portal, click on **Insights** under **Monitoring**, click on the **Containers** tab and pick a container to view its live logs and debug what is going on.

![Azure Monitor for Containers: Live Logs](media/livelogs.png)

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/application-insights/app-insights-alerts?wt.mc_id=CSE_(606698)>
> * <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview>
> * <https://coreos.com/operators/prometheus/docs/latest/>