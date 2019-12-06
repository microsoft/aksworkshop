---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service), we'll use this to easily deploy and standup a Kubernetes cluster.

### Tasks

#### Get the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available Kubernetes version in your preferred region into a bash variable. Replace `<region>` with the region of your choosing, for example `eastus`. The query also filters out preview versions.

```sh
version=$(az aks get-versions -l <region> --query 'orchestrators[?!isPreview] | [-1].orchestratorVersion' -o tsv)
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

**Task Hints**
* It's recommended to use the Azure CLI and the `az aks create` command to deploy your cluster. Refer to the docs linked in the Resources section, or run `az aks create -h` for details
* The size and number of nodes in your cluster is not critical but two or more nodes of `DS2_v2` or larger is recommended

> **Note** You can create AKS clusters that support the [cluster autoscaler](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler#about-the-cluster-autoscaler).

##### **Option 1:** Create an AKS cluster without the cluster autoscaler (recommended)

Create AKS using the latest version (if using the provided lab environment)
  
{% collapsible %}
  
> **Note** If you're using the provided lab environment, you'll not be able to create the Log Analytics workspace required to enable monitoring while creating the cluster from the Azure Portal unless you manually create the workspace in your assigned resource group. Additionally, if you're running this on an Azure Pass, please add `--load-balancer-sku basic` to the flags, as the Azure Pass only supports the basic Azure Load Balancer. Additionaly, please pass in the service prinipal and secret provided.

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
  
  Create AKS using the latest version (on your own subscription)
  
  {% collapsible %}

  ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys
  ```

  {% endcollapsible %}

##### **Option 2 ** Create an AKS cluster with the cluster autoscaler

 
  AKS clusters that support the cluster autoscaler must use virtual machine scale sets and run Kubernetes version *1.12.4* or later. 

  Use the `az aks create` command specifying the `--enable-cluster-autoscaler` parameter, and a node `--min-count` and `--max-count`.
  
Create AKS using the latest version (if using the provided lab environment)

{% collapsible %}

> **Note** If you're running this on an Azure Pass or the provided lab environment, please add `--load-balancer-sku basic` to the flags, as the Azure Pass only supports the basic Azure Load Balancer. Additionaly, please pass in the service prinipal and secret provided.

   ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys \
    --vm-set-type VirtualMachineScaleSets \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3 \
    --load-balancer-sku basic \
    --service-principal <APP_ID> \
    --client-secret <APP_SECRET>
  ```

{% endcollapsible %}
  
Create AKS using the latest version (on your own subscription)

{% collapsible %}

   ```sh
  az aks create --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --location <region> \
    --kubernetes-version $version \
    --generate-ssh-keys \
    --vm-set-type VirtualMachineScaleSets \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3
  ```

  {% endcollapsible %}

#### Ensure you can connect to the cluster using `kubectl`

**Task Hints**
* `kubectl` is the main command line tool you will using for working with Kubernetes and AKS. It is already installed in the Azure Cloud Shell
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

List the available nodes

```sh
kubectl get nodes
```

{% endcollapsible %}

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough-portal>
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough#connect-to-the-cluster>
> * <https://linuxacademy.com/site-content/uploads/2019/04/Kubernetes-Cheat-Sheet_07182019.pdf>
