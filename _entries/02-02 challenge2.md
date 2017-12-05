---

sectionid: apidb
sectionclass: h2
parent-id: upandrunning
title: Deploy the order capture API and DB
---

You need to deploy the order capture API. This requires an external endpoint and
needs to write to MongoDB.

![](media/51744cdc31c555b1d76c71f5e2693471.png)

Once deployed please provide your proctor with a **DNS name** for your order
capture API so service availability and performance can be monitored.

1.  Deploy an instance of MongoDB to your cluster

2.  Create Kubernetes YAML files to deploy the order management service and
    expose a public endpoint

3.  Ensure orders are successfully written to MongoDB

Resources:

-   <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

-   <https://kubernetes.io/docs/concepts/services-networking/service/>

-   <https://helm.sh/>

-   <https://kubeapps.com/charts/stable/mongodb>

-   <https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec>

-   If using AKS: <https://github.com/Azure/AKS/issues/48>
