---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service).

**You will need to use features available in Kubernetes 1.11.**

> **Hint** Enable Kubernetes Role-based access control (RBAC) which provides fine-grained control over cluster resources when creating the cluster because **you can't enable it post cluster creation**. RBAC enabled clusters by default have degraded Kubernetes Dashboard functionality. This is a good security practice because it avoids unintended privelage escalation.

### Tasks

#### Deploy Kubernetes to Azure, using CLI or Azure portal using the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available Kubernetes version

```sh
az aks get-versions -l eastus -o table
```

Create a Resource Group

```sh
az group create --name akschallenge --location eastus
```

Create AKS using the latest version and enable the monitoring addon

```sh
az aks create --resource-group akschallenge --name <unique-aks-cluster-name> --enable-addons monitoring --kubernetes-version 1.11.5 --generate-ssh-keys --location eastus
```

> **Important**: If you are using Service Principal authentication, for example in a lab environment, you'll need to use an alternate command to create the cluster with your existing Service Principal passing in the `Application Id` and the `Application Secret Key`.
> ```sh
> az aks create --resource-group akschallenge --name <unique-aks-cluster-name> --enable-addons monitoring --kubernetes-version 1.11.5 --generate-ssh-keys --location eastus --service-principal APP_ID --client-secret "APP_SECRET"
> ```

Install the Kubernetes CLI

```sh
az aks install-cli
```

{% endcollapsible %}

#### Ensure you and your colleagues can connect to the cluster using `kubectl`

{% collapsible %}

Authenticate

```sh
az aks get-credentials --resource-group akschallenge --name <unique-aks-cluster-name>
```

List the available nodes

```sh
kubectl get nodes
```

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal>