---

sectionid: apidb
sectionclass: h2
parent-id: upandrunning
title: Deploy the Order Capture API and MongoDB
---

You need to deploy the **Order Capture API**. This requires an external endpoint, exposing the API on port 80 and needs to write to MongoDB.

![Application components](media/51744cdc31c555b1d76c71f5e2693471.png)


1. Deploy an instance of MongoDB to your cluster

1. Create Kubernetes YAML files to deploy the Capture Order service and expose a public endpoint.

1. Ensure orders are successfully written to MongoDB

> **Hint** take a few minutes to discuss with your team mates how are you going share the YAML files amongst yourselves. Git? OneDrive? Email :)

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> *  <https://kubernetes.io/docs/concepts/services-networking/service/>
> * <https://helm.sh/>
> * <https://kubeapps.com/charts/stable/mongodb>
> * <https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#exec>
