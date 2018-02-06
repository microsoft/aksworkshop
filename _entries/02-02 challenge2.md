---

sectionid: apidb
sectionclass: h2
parent-id: upandrunning
title: Deploy the Order Capture API and MongoDB
---

You need to deploy the order capture API. This requires an external endpoint, exposing the API on port 80 and
needs to write to MongoDB.

![](media/51744cdc31c555b1d76c71f5e2693471.png)

Once deployed please provide your proctor with a Public IP for your Order Capture API so service availability and performance can be monitored.
**Note, any changes to your public IP during the hack may cause downtime. It is recommended that you deploy it
in a manner that will ensure it does not change.**

1.  Deploy an instance of MongoDB to your cluster

2.  Create Kubernetes YAML files to deploy the Capture Order service and expose a public endpoint. **Ensure you are using the most recent version of the image**

3.  Ensure orders are successfully written to MongoDB

Resources:

-   <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>

-   <https://kubernetes.io/docs/concepts/services-networking/service/>

-   <https://helm.sh/>

-   <https://kubeapps.com/charts/stable/mongodb>

-   <https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec>
