---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service). We'll use this to easily deploy and standup a Kubernetes cluster.

### Tasks

#### Get the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available non-preview Kubernetes version in your preferred region and store it in a bash variable. Replace `<region>` with the region of your choosing, for example `eastus`.

```sh
version=$(az aks get-versions -l <region> --query 'orchestrators[?isPreview == null].[orchestratorVersion][-1]' -o tsv)
```

{% endcollapsible %}

#### Create a Resource Group

> **Note** You don't need to create a resource group if you're using the lab environment. You can use the resource group created for you as part of the lab. To retrieve the resource group name in the managed lab environment, run `az group list`.

{% collapsible %}

This is for reference only. For this lab, we're using the resource group already created for you lab environment as noted above.

```sh
az group create --name <resource-group> --location <region>
```

{% endcollapsible %}

#### Create the AKS cluster

**Task Hints**
* It's recommended to use the Azure CLI and the `az aks create` command to deploy your cluster. Refer to the docs linked in the Resources section, or run `az aks create -h` for details
* The size and number of nodes in your cluster is not critical but two or more nodes of type `Standard_DS2_v2` or larger is recommended
  
{% collapsible %}

  ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys \
    --load-balancer-sku basic \
    --service-principal <APP_ID> \
    --client-secret <APP_SECRET>
  ```

{% endcollapsible %}

#### Ensure you can connect to the cluster using `kubectl`

**Task Hints**
* `kubectl` is the main command line tool you will be using for working with Kubernetes and AKS. It is already installed in the Azure Cloud Shell
* Refer to the AKS docs which includes [a guide for connecting kubectl to your cluster](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster) (Note. using the cloud shell you can skip the `install-cli` step).
* A good sanity check is listing all the nodes in your cluster `kubectl get nodes`.
* [This is a good cheat sheet](https://linuxacademy.com/site-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf) for kubectl.
* If you run kubectl in PowerShell ISE , you can also define aliases :
```sh
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { & kubectl $params }
function kubectl([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> kubectl $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
function k([Parameter(ValueFromRemainingArguments = $true)]$params) { Write-Output "> k $(@($params | ForEach-Object {$_}) -join ' ')"; & kubectl.exe $params; }
```

{% collapsible %}
> **Note** `kubectl`, the Kubernetes CLI, is already installed on the Azure Cloud Shell.

Authenticate

```sh
az aks get-credentials --resource-group <resource-group> --name <unique-aks-cluster-name>
```

Check cluster connectivity by listing the nodes in your cluster

```sh
kubectl get nodes
```
{% endcollapsible %}

> **Resources**
>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster>
> * <https://linuxacademy.com/site-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf>
