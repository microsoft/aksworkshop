---
sectionid: deploy
sectionclass: h2
title: Deploy Kubernetes
parent-id: upandrunning
---

Your organisation requires that the application is deployed to Kubernetes running on
Azure. You will need to use features available in Kubernetes 1.8. Be aware that ACS 
currently only supports Kubernetes 1.7. 

Given the limited budget allocated for the
project you should think very carefully before deploying more than three Kubernetes agent nodes. If you run out credit expect you will
experience downtime.

You have also found out that Azure has a managed Kubernetes service, AKS (Azure Kubernetes Service). This is currently in preview, and at the time of writing the default version of Kubernetes deployed is 1.7.7, but AKS does support version 1.8.

You need to:

1. Deploy Kubernetes to Azure
2. Ensure you and your colleagues can connect to the cluster using kubectl

Resources:
- AKS: <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster?wt.mc_id=CSE_(96575)> ( <https://github.com/Azure/AKS/issues> )
- ACS Engine: 

    If you need to run ACS-Engine to generate a version 1.8 Kubernetes cluster, follow these steps:
    
    1. Download ACS-Engine to generate a custom Kubernetes ARM infrastructure-as-code template from here <https://github.com/Azure/acs-engine/releases/tag/v0.10.0>
    2. Download the Kubernetes 1.8 API Model template from here <https://github.com/Azure/acs-engine/blob/master/examples/kubernetes-releases/kubernetes1.8.json>
    3. Generate a Service Principle (SP)
    4. Generate a ssh key
    5. Populate the 1.8 API Model template with the SP and ssh key
    4. Run the following command: ./acs-engine generate --api-model [1.8 API Model.json] --output-directory ./out/. This will generate files in the out folder
    4. Now run az group deployment create \
        --name "[your cluster name]" \
        --resource-group "[your resource group]" \
        --template-file "./out/azuredeploy.json" \ 
        --parameters "./out/azuredeploy.parameters.json"
    - Kubectl overview
    - <https://kubernetes.io/docs/reference/kubectl/overview/>
