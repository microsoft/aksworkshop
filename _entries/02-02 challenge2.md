---
sectionclass: h2
sectionid: acr
parent-id: upandrunning
title: Create private highly available container registry 
---

Instead of using the public Docker Hub registry, create your own private container registry using Azure Container Registry (ACR).

### Tasks

#### Create an Azure Container Registry (ACR)


```sh
export ACR_NAME=akschallenge${RANDOM}$$; echo $ACR_NAME
az acr create --resource-group akschallenge --name ${ACR_NAME} --sku Standard
```

##### Grant AKS access to Azure Container Registry

Authorize the AKS cluster to connect to the Azure Container Registry using the AKS cluster's Service Principal.

Follow the Azure docs to learn how to [grant access using Azure Active Directory Service Principals](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks).


```sh
export AKS_RESOURCE_GROUP=akschallenge
export AKS_CLUSTER_NAME=akschallenge

# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $AKS_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID
```

> **Resources**
>
> * <https://docs.microsoft.com/en-us/azure/container-registry>
> * <https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks>
> * <https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az-acr-build>