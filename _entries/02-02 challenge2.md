---

sectionid: apidb
sectionclass: h2
parent-id: upandrunning
title: Deploy the Order Capture API and MongoDB
---

You need to deploy the **Order Capture API** ([azch/captureorder](https://hub.docker.com/r/azch/captureorder/)). This requires an external endpoint, exposing the API on port 80 and needs to write to MongoDB.

> **Hints**
> * Take a few minutes to discuss with your team mates how are you going share the YAML files amongst yourselves. Git? OneDrive? Email (!)
> * Consider deploying MongoDB in a way that is scalable and production ready.
> * Be careful with the authentication settings when creating MongoDB. It is recommended that you create a standalone username/password and database.
> * **Important**: If you install using Helm and then delete the release, the MongoDB data and configuration persists in a Persistent Volume Claim. You may face issues if you redploy again using the same release name because the authentication configuration will not match.

![Application components](media/captureorder.png)

### Tasks

1. Deploy an instance of MongoDB to your cluster. The application expects a database called `akschallenge`
1. Provision the `captureorder` deployment and expose a public endpoint
1. Ensure orders are successfully written to MongoDB

> **Resources**
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm>
> * <https://github.com/helm/charts/tree/master/stable/mongodb#production-settings-and-horizontal-scaling>
> * <https://kubernetes.io/docs/concepts/configuration/secret/>
