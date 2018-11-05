---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes with Azure Kubernetes Service (AKS)
parent-id: upandrunning
---

Your organisation requires that the application is deployed to Kubernetes running on Azure. You will need to use features available in Kubernetes 1.8.

You have found out that Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service). This is currently in preview, and at the time of writing the default version of Kubernetes deployed is 1.7.7, but AKS does support version 1.8.
You need to:

1. Deploy Kubernetes to Azure, using CLI or Azure portal
2. Ensure you and your colleagues can connect to the cluster using kubectl

Resources:
- AKS:

    [https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?wt.mc_id=CSE_(433127))

    [AKS Issues](https://github.com/Azure/AKS/issues)


- ACS Engine:

    If you need to run ACS-Engine to generate a version 1.8 Kubernetes cluster, please follow these steps:
    
    1. [Download ACS-Engine to generate a custom Kubernetes ARM infrastructure-as-code template](https://github.com/Azure/acs-engine/releases)

    2. [Download the Kubernetes 1.8 API Model template](https://github.com/Azure/acs-engine/blob/master/examples/kubernetes-releases/kubernetes1.8.json)

    3. [Generate a Service Principle (SP)](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?toc=%2Fazure%2Fazure-resource-manager%2Ftoc.json&view=azure-cli-latest?wt.mc_id=CSE_(433127))

    4. [Generate a ssh key](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys?wt.mc_id=CSE_(433127))

    5. Populate the 1.8 API Model template with the service principal and ssh key you generated

    6. Run the following command:

            ```
                ./acs-engine generate --api-model [path_to/kubernetes1.8.json] --output-directory ./out/
            ```
                
        This will generate files in the ```out``` folder.

    7. Now run the following command to deploy the cluster:

        ```
            az group deployment create \
            --name "[your cluster name]" \
            --resource-group "[your resource group]" \
            --template-file "./out/azuredeploy.json" \
            --parameters "./out/azuredeploy.parameters.json"
        ```

[https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?wt.mc_id=CSE_(606698))

[AKS Issues](https://github.com/Azure/AKS/issues)
