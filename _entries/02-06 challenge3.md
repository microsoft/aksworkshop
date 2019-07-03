---
sectionid: monitoring
sectionclass: h2
parent-id: upandrunning
title: Monitoring
---

You would like to monitor the performance of different components in your application, view logs and get alerts whenever your application availability goes down or some components fail.

Use a combination of the available tools to setup alerting capabilities for your application.

> **Note** If you are running this lab as part of the managed lab environment, you may not be able to create the required resources to enable monitoring due to insufficient permissions on the subscription.

### Tasks

#### Leverage integrated Azure Kubernetes Service monitoring to figure out if requests are failing, inspect logs and monitor your cluster health

If you didn't create an AKS cluster with monitoring enabled, you can enable the add-on by running:

```sh
az aks enable-addons --resource-group akschallenge --name <unique-aks-cluster-name> --addons monitoring
```

{% collapsible %}

- Check the cluster utilization under load
  ![Cluster utilization](media/clusterutilization.png)

- Identify which pods are causing trouble
  ![Pod utilization](media/podmetrics.png)

{% endcollapsible %}

#### View the live container logs and Kubernetes events

{% collapsible %}

**If the cluster is RBAC enabled**, you have to create the appropriate `ClusterRole` and `ClusterRoleBinding`.

Save the YAML below as `logreader-rbac.yaml` or download it from [logreader-rbac.yaml](yaml-solutions/01. challenge-03/logreader-rbac.yaml)

```yaml
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRole 
metadata: 
   name: containerHealth-log-reader 
rules: 
   - apiGroups: [""] 
     resources: ["pods/log", "events"] 
     verbs: ["get", "list"]  
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

If you have a Kubernetes cluster that is not configured with Kubernetes RBAC authorization or integrated with Azure AD single-sign on, you do not need to follow the steps above. Because Kubernetes authorization uses the kube-api, contributor access is required.

Head over to the AKS cluster on the Azure portal, click on **Insights** under **Monitoring**, click on the **Containers** tab and pick a container to view its live logs and debug what is going on.

![Azure Monitor for Containers: Live Logs](media/livelogs.png)

{% endcollapsible %}

> **Resources**
> - <https://docs.microsoft.com/en-us/azure/application-insights/app-insights-alerts>
> - <https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-live-logs>
> - <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview>
> - <https://coreos.com/operators/prometheus/docs/latest/>