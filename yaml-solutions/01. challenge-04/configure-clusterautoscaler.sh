#! /bin/bash
ID=`az account show --query id -o json`
SUBSCRIPTION_ID=`echo $ID | tr -d '"' `

TENANT=`az account show --query tenantId -o json`
TENANT_ID=`echo $TENANT | tr -d '"' | base64`

read -p "What's your cluster name? " cluster_name
read -p "Resource group name? " resource_group

CLUSTER_NAME=`echo $cluster_name | base64`
RESOURCE_GROUP=`echo $resource_group | base64`

PERMISSIONS=`az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" -o json`
CLIENT_ID=`echo $PERMISSIONS | sed -e 's/^.*"appId"[ ]*:[ ]*"//' -e 's/".*//' | base64`
CLIENT_SECRET=`echo $PERMISSIONS | sed -e 's/^.*"password"[ ]*:[ ]*"//' -e 's/".*//' | base64`

SUBSCRIPTION_ID=`echo $ID | tr -d '"' | base64 `

NODE_RESOURCE_GROUP=`az aks show --name $cluster_name  --resource-group $resource_group -o tsv --query 'nodeResourceGroup' | base64`

echo "---
apiVersion: v1
kind: Secret
metadata:
    name: cluster-autoscaler-azure
    namespace: kube-system
data:
    ClientID: $CLIENT_ID
    ClientSecret: $CLIENT_SECRET
    ResourceGroup: $RESOURCE_GROUP
    SubscriptionID: $SUBSCRIPTION_ID
    TenantID: $TENANT_ID
    VMType: QUtTCg==
    ClusterName: $CLUSTER_NAME
    NodeResourceGroup: $NODE_RESOURCE_GROUP
---"