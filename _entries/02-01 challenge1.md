---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service).

**Deploy the latest Kubernetes version available in AKS**

> **Hint** Enable Kubernetes Role-based access control (RBAC), which provides fine-grained control over cluster resources when creating the cluster because **you can't enable it post cluster creation**. RBAC enabled clusters by default have degraded Kubernetes Dashboard functionality. This is a good security practice because it avoids unintended privilege escalation.

### Tasks

#### Deploy Kubernetes to Azure, using CLI or Azure portal using the latest Kubernetes version available in AKS

Create a Resource Group for your AKS cluster. When you joined the workshop, you should have been assigned a location for your AKS cluster. Use the command below, and make sure you specify your assigned region.

```sh
az group create --name akschallenge --location YOURREGION
```

Pick a random region
```
centralus
eastus
eastus2
westus
northcentralus
southcentralus
```

Create a new cluster using the latest version

```sh
az aks create --resource-group akschallenge --name akschallenge \
    --kubernetes-version 1.13.5 --generate-ssh-keys
```

> **Important**: For the lab, you'll need to use an alternate command to create the cluster with your existing Service Principal passing in the `Application Id` and the `Application Secret Key`.
> ```sh
> az aks create --resource-group akschallenge --name akschallenge \
>   --enable-addons monitoring,http_application_routing \
>   --kubernetes-version 1.13.5 --generate-ssh-keys \
>   --service-principal <APP_ID> --client-secret <APP_SECRET>
> ```

#### Ensure you and your colleagues can connect to the cluster using `kubectl`


Authenticate with Azure and obtain a `kubeconfig` file with credentials to access the cluster

```sh
az aks get-credentials --resource-group akschallenge --name akschallenge
```

Check cluster connectivity by listing the nodes in your cluster

```sh
kubectl get nodes
```


> **Resources**
>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal>