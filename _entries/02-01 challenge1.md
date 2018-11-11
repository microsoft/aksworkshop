---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Your organisation requires that the application is deployed to Kubernetes running on Azure. **You will need to use features available in Kubernetes 1.11.**

You have found out that Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service).

> **Hint** Enable Kubernetes Role-based access cntrol (RBAC) which provides fine-grained control over cluster resources when creating the cluster because **you can't enable it post cluster creation**. RBAC enabled clusters by default have degraded Kubernetes Dashboard functionality. This is a good security practice because it avoids unintended privelage escalation.

### Tasks

1. Deploy Kubernetes to Azure, using CLI or Azure portal using the latest Kubernetes version available in AKS
2. Ensure you and your colleagues can connect to the cluster using `kubectl`

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough?wt.mc_id=CSE_(433127)>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create?wt.mc_id=CSE_(433127)>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal?wt.mc_id=CSE_(433127)>