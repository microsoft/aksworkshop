---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service).

**Deploy the latest Kubernetes version available in AKS**

> **Hint** Enable Kubernetes Role-based access control (RBAC) which provides fine-grained control over cluster resources when creating the cluster because **you can't enable it post cluster creation**. RBAC enabled clusters by default have degraded Kubernetes Dashboard functionality. This is a good security practice because it avoids unintended privelage escalation.

### Tasks

#### Deploy Kubernetes to Azure, using CLI or Azure portal using the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available Kubernetes version

```sh
region=<targeted AKS region>
az aks get-versions -l $region -o table
kubernetesVersionLatest=$(az aks get-versions -l ${region} --query 'orchestrators[-1].orchestratorVersion' -o tsv)
```

Create a Resource Group

```sh
az group create --name akschallenge --location $region
```

Create AKS using the latest version and enable the monitoring addon

```sh
az aks create --resource-group akschallenge --name <unique-aks-cluster-name> --enable-addons monitoring --kubernetes-version $kubernetesVersionLatest --generate-ssh-keys --location eastus
```

> **Important**: If you are using Service Principal authentication, for example in a lab environment, you'll need to use an alternate command to create the cluster with your existing Service Principal passing in the `Application Id` and the `Application Secret Key`.
> ```sh
> az aks create --resource-group akschallenge --name <unique-aks-cluster-name> --enable-addons monitoring --kubernetes-version $kubernetesVersionLatest --generate-ssh-keys --location eastus --service-principal APP_ID --client-secret "APP_SECRET"
> ```

Install the Kubernetes CLI

```sh
az aks install-cli
```

> **Note** If you're running this on the Azure Cloud Shell, you may receive a "Permission Denied" error as the Kubernetes CLI (`kubectl`) is already installed. If this is the case, just go to the next step.

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