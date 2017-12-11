---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes
parent-id: upandrunning
---

Your organisation requires that the application is deployed to Kubernetes running on
Azure. You may wish to use features available in Kubernetes 1.8. Be aware that ACS only
currently supports Kubernetes 1.7. Given the limited budget allocated for the
project you must not deploy only three Kubernetes agent nodes. If you run out credit expect you will
experience downtime.

You have also found out that Azure has a managed Kubernetes service, 
AKS (Azure Kubernetes Service) which is currently in Preview and deploys version 1.8+

You need to:

1. Deploy Kubernetes to Azure
2. Ensure you and your colleagues can connect to the cluster using kubectl

Resources:

- ACS: <https://docs.microsoft.com/en-us/azure/container-service/kubernetes/>
- AKS: <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster>
- ACS Engine: XXX
- <https://kubernetes.io/docs/reference/kubectl/overview/>
