---
sectionid: monitoring
sectionclass: h2
parent-id: upandrunning
title: Monitoring
---

You would like to monitor the performance of different components in your application, view logs and get alerts whenever your application availability goes down or some components fail.

Use a combination of the available tools to setup alerting capabilities for your application.

### Tasks

#### Create Log Analytics workspace

**Task Hints**
* To store monitoring data, events and metrics from your Kubernetes cluster and the applications, Azure Monitor can be used. Specifically a component of Azure Monitor called [Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/log-query/get-started-portal).
* The Azure documentation has [guidance on how to create a new Log Analytics workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace) using the portal.

{% collapsible %}

If you are running this lab as part of the managed lab environment, you may not be able to create the required resources to enable monitoring due to insufficient permissions on the subscription. You'll need to pre-create the Log Analytics workspace in your assigned environment resource group.

Follow the [Create a Log Analytics workspace in the Azure portal](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace) instructions.

Alternatively you can create the workspace using the CLI with the command below, ensure you pick a unique name for the workspace
```sh
az resource create --resource-type Microsoft.OperationalInsights/workspaces \
 --name <workspace-name> \
 --resource-group <resource-group> \
 --location <region> \
 --properties '{}' -o table
```

{% endcollapsible %}

#### Enable the monitoring addon

**Task Hints**
* The monitoring add-on, also known as "Azure Monitor for containers" is [a comprehensive monitoring solution for Kubernetes](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview)
* To enable the add-on you can use the portal or the Azure CLI, and [integrate with the existing workspace you created in the last task](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-enable-existing-clusters#integrate-with-an-existing-workspace)

{% collapsible %}

First get the resource id of the workspace you created, by running

```sh
az resource show --resource-type Microsoft.OperationalInsights/workspaces --resource-group <resource-group> --name <workspace-name> --query "id" -o tsv
```

Next enable the monitoring add-on by running the command below, replace the placeholder values and the *workspace-resource-id* value with the output from the previous command

```sh
az aks enable-addons --resource-group <resource-group> --name <unique-aks-cluster-name> --addons monitoring --workspace-resource-id <workspace-resource-id>
```

{% endcollapsible %}

#### Leverage integrated Azure Kubernetes Service monitoring to figure out if requests are failing, inspect Kubernetes events or logs and monitor your cluster health

**Task Hints**
* View the utilization reports and charts in the Azure portal, via the "Insights" view on your AKS cluster
* It might be several minutes before the data appears

{% collapsible %}

- Check the cluster utilization under load
  ![Cluster utilization](media/clusterutilization.png)

- Identify which pods are causing trouble
  ![Pod utilization](media/podmetrics.png)

{% endcollapsible %}

#### View the live container logs and Kubernetes events

**Task Hints**
* You can view live log data from the 'Containers' tab in the Insights view, with the "View live data (preview)" button.
* You will get an error which can be fixed by setting up some RBAC roles and accounts in your cluster. [This is covered in the AKS documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-live-logs). You might need to refresh the page in the portal for the changes to take effect.

{% collapsible %}

**If the cluster is RBAC enabled, which is the default**, you have to create the appropriate `ClusterRole` and `ClusterRoleBinding`.

Save the YAML below as `logreader-rbac.yaml` or download it from [logreader-rbac.yaml](yaml-solutions/01. challenge-03/logreader-rbac.yaml)

```yaml
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRole 
metadata: 
   name: containerHealth-log-reader 
rules: 
    - apiGroups: ["", "metrics.k8s.io", "extensions", "apps"]
      resources:
         - "pods/log"
         - "events"
         - "nodes"
         - "pods"
         - "deployments"
         - "replicasets"
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

Head over to the AKS cluster on the Azure portal, click on **Insights** under **Monitoring**, click on the **Controllers** tab and pick a container to view its live logs or event logs and debug what is going on.

![Azure Monitor for Containers: Live Logs](media/livelogs.png)

{% endcollapsible %}

#### Collect Prometheus metrics (optional)

{% collapsible %}

> **Note** The minimum agent version supported by this feature is microsoft/oms:ciprod07092019 or later.

1. Run an demo application called “prommetrics-demo” which already has the Prometheus endpoint exposed.
Save the YAML below as `prommetrics-demo.yaml` or download it from [prommetrics-demo.yaml](yaml-solutions/01. challenge-03/prommetrics-demo.yaml)

  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: prommetrics-demo
    labels:
      app: prommetrics-demo
  spec:
    selector:
      app: prommetrics-demo
    ports:
    - name: metrics
      port: 8000
      protocol: TCP
      targetPort: 8000
    - name: http
      port: 8080
      protocol: TCP
      targetPort: 8080
    type: ClusterIP
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: prommetrics-demo
    labels:
      app: prommetrics-demo
  spec:
    replicas: 4
    selector:
      matchLabels:
        app: prommetrics-demo
    template:
      metadata:
        annotations:
          prometheus.io/scrape: "true"
          prometheus.io/path: "/"
          prometheus.io/port: "8000"
        labels:
          app: prommetrics-demo
      spec:
        containers:
        - name: prommetrics-demo
          image: vishiy/tools:prommetricsv5
          imagePullPolicy: Always
          ports:
          - containerPort: 8000
          - containerPort: 8080
  ```
  And deploy it using

  ```sh
  kubectl apply -f prommetrics-demo.yaml
  ```
  This application on purpose generates *"Bad Request 500"* when traffic is generated and it exposes a Prometheus metric called **prommetrics_demo_requests_counter_total.** 

2. Generate traffic to the application by running curl. 

  Find the pods you just created.

  ```sh
  kubectl get pods | grep prommetrics-demo

  prommetrics-demo-7f455766c4-gmpjb   1/1       Running   0          2m
  prommetrics-demo-7f455766c4-n7554   1/1       Running   0          2m
  prommetrics-demo-7f455766c4-q756r   1/1       Running   0          2m
  prommetrics-demo-7f455766c4-vqncw   1/1       Running   0          2m
  ```
  Select one of the pods and login. 

  ```sh
  kubectl exec -it prommetrics-demo-7f455766c4-gmpjb bash
  ```

  While logged on, execute curl to generate traffic. 

  ```sh
  while (true); do curl 'http://prommetrics-demo.default.svc.cluster.local:8080'; sleep 5; done 
  ```

  > **Note** Leave the window open and keep running this. You will see **"Internal Server Error"** but do not close the window. 

3.	Download the configmap template yaml file and apply to start scraping the metrics. 
  
  This configmap is pre-configured to scrape the application pods and collect Prometheus metric **“prommetrics_demo_requests_counter_total”** from the demo application in 1min interval. 

  Download configmap from [configmap.yaml](yaml-solutions/01. challenge-03/configmap.yaml)

  ```
  interval = "1m"
  fieldpass = ["prommetrics_demo_requests_counter_total"]
  monitor_kubernetes_pods = true
  ```
  And deploy it using

  ```sh
  kubectl apply -f configmap.yaml
  ```

4.	Query the Prometheus metrics and plot a chart. 

  To access Log Analytics, go to the overview page for your AKS cluster and click `Logs` in the list of options on the left hand side under Monitor. 
 
 Copy the query below and run. 

 > **Note** It can take several minutes for the log data to appear in Log Analytics. If you see "NO RESULTS FOUND", maybe try the next exercise and return later to view the data.

  ```
  InsightsMetrics
  | where Name == "prommetrics_demo_requests_counter_total"
  | extend dimensions=parse_json(Tags)
  | extend request_status = tostring(dimensions.request_status)
  | where request_status == "bad"
  | project request_status, Val, TimeGenerated | render timechart
  ```
  You should be able to plot a chart based on the Prometheus metrics collected. 

  ![Azure Monitor for Containers: Prometheus](media/prommetric.png)

{% endcollapsible %}

> **Resources**
> - <https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview>
> - <https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace>
> - <https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-live-logs>
> - <https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-overview>
> - <https://coreos.com/operators/prometheus/docs/latest/>
