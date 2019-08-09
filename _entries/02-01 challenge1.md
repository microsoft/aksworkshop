---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service).

### Tasks

#### Get the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available Kubernetes version in your preferred region into a bash variable. Replace `<region>` with the region of your choosing, for example `eastus`.

```sh
version=$(az aks get-versions -l <region> --query 'orchestrators[-1].orchestratorVersion' -o tsv)
```

{% endcollapsible %}

#### Create a Resource Group

> **Note** You don't need to create a resource group if you're using the lab environment. You can use the resource group created for you as part of the lab. To retrieve the resource group name in the managed lab environment, run `az group list`.

{% collapsible %}

```sh
az group create --name <resource-group> --location <region>
```

{% endcollapsible %}

#### Create the AKS cluster

> **Note** You can create AKS clusters that support the [cluster autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler). However, please note that the AKS cluster autoscaler is a preview feature, and enabling it is a more involved process. AKS preview features are self-service and opt-in. Previews are provided to gather feedback and bugs from our community. However, they are not supported by Azure technical support. If you create a cluster, or add these features to existing clusters, that cluster is unsupported until the feature is no longer in preview and graduates to general availability (GA).

##### **Option 1:** Create an AKS cluster without the cluster autoscaler

> **Note** If you're using the provided lab environment, you'll not be able to create the Log Analytics workspace required to enable monitoring while creating the cluster from the Azure Portal unless you manually create the workspace in your assigned resource group.

  {% collapsible %}

  Create AKS using the latest version

  ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys
  ```

  {% endcollapsible %}

##### **Option 2 (*Preview*):** Create an AKS cluster with the cluster autoscaler

> **Note** This will not work in the lab environment. You can only do this on a subscription where you have access to enable preview features.

  {% collapsible %}
 
  AKS clusters that support the cluster autoscaler must use virtual machine scale sets and run Kubernetes version *1.12.4* or later. This scale set support is in preview. To opt in and create clusters that use scale sets, first install the *aks-preview* Azure CLI extension using the `az extension add` command, as shown in the following example:

  ```sh
  az extension add --name aks-preview
  ```

  To create an AKS cluster that uses scale sets, you must also enable a feature flag on your subscription. To register the *VMSSPreview* feature flag, use the `az feature register` command as shown in the following example:

  ```sh
  az feature register --name VMSSPreview --namespace Microsoft.ContainerService
  ```

  It takes a few minutes for the status to show *Registered*. You can check on the registration status using the `az feature list` command:

  ```sh
  az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/VMSSPreview')].{Name:name,State:properties.state}"
  ```

  When ready, refresh the registration of the *Microsoft.ContainerService* resource provider using the `az provider register` command:

  ```sh
  az provider register --namespace Microsoft.ContainerService
  ```

  Use the `az aks create` command specifying the `--enable-cluster-autoscaler` parameter, and a node `--min-count` and `--max-count`.

  > **Note** During preview, you can't set a higher minimum node count than is currently set for the cluster. For example, if you currently have min count set to *1*, you can't update the min count to *3*.

   ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys \
    --enable-vmss \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3
  ```

  {% endcollapsible %}

#### Ensure you can connect to the cluster using `kubectl`

{% collapsible %}

> **Note** `kubectl`, the Kubernetes CLI, is already installed on the Azure Cloud Shell.

Authenticate

```sh
az aks get-credentials --resource-group <resource-group> --name <unique-aks-cluster-name>
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