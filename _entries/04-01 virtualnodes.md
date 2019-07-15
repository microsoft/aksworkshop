---
sectionid: virtualnodes
sectionclass: h2
title: "New cluster: AKS with Virtual Nodes"
parent-id: advancedclustersetup
---

To rapidly scale application workloads in an Azure Kubernetes Service (AKS) cluster, you can use Virtual Nodes. With Virtual Nodes, you have quick provisioning of pods, and only pay per second for their execution time. You don't need to wait for Kubernetes cluster autoscaler to deploy VM compute nodes to run the additional pods.


> **Note**
> - We will be using virtual nodes to scale out our API using Azure Container Instances (ACI).
> - These ACI's will be in a private VNET, so we must deploy a new AKS cluster with advanced networking.
> - Take a look at documentation for [regional availability](https://docs.microsoft.com/en-us/azure/aks/virtual-nodes-cli#regional-availability) and [known limitations](https://docs.microsoft.com/en-us/azure/aks/virtual-nodes-cli#known-limitations)

### Tasks

#### Create a virtual network and subnet

Virtual nodes enable network communication between pods that run in Azure Container Instances (ACI) and the AKS cluster. To provide this communication, a virtual network subnet is created and delegated permissions are assigned. Virtual nodes only work with AKS clusters created using advanced networking.

{% collapsible %}

Create a VNET

```bash
az network vnet create \
    --resource-group <resource-group> \
    --name myVnet \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name myAKSSubnet \
    --subnet-prefix 10.240.0.0/16
```

And an additional subnet

```bash
az network vnet subnet create \
    --resource-group <resource-group> \
    --vnet-name myVnet \
    --name myVirtualNodeSubnet \
    --address-prefix 10.241.0.0/16
```

{% endcollapsible %}

#### Create a service principal and assign permissions to VNET

{% collapsible %}

Create a service principal

```bash
az ad sp create-for-rbac --skip-assignment
```

Output will look similar to below. You will use the `appID` and `password` in the next step.

```json
{
  "appId": "7248f250-0000-0000-0000-dbdeb8400d85",
  "displayName": "azure-cli-2017-10-15-02-20-15",
  "name": "http://azure-cli-2017-10-15-02-20-15",
  "password": "77851d2c-0000-0000-0000-cb3ebc97975a",
  "tenant": "72f988bf-0000-0000-0000-2d7cd011db47"
}
```

Assign permissions. We will use this same SP to create our AKS cluster.

```bash
APPID=<replace with above>
PASSWORD=<replace with above>

VNETID=$(az network vnet show --resource-group <resource-group> --name myVnet --query id -o tsv)

az role assignment create --assignee $APPID --scope $VNETID --role Contributor
```

{% endcollapsible %}

#### Get the latest Kubernetes version available in AKS

{% collapsible %}

Get the latest available Kubernetes version in your preferred region into a bash variable. Replace `<region>` with the region of your choosing, for example `eastus`.

```sh
VERSION=$(az aks get-versions -l <region> --query 'orchestrators[-1].orchestratorVersion' -o tsv)
```

{% endcollapsible %}

#### Register the Azure Container Instances service provider

{% collapsible %}

If you have not previously used ACI, register the service provider with your subscription. You can check the status of the ACI provider registration using the `az provider list` command, as shown in the following example:

```bash
az provider list --query "[?contains(namespace,'Microsoft.ContainerInstance')]" -o table
```

The *Microsoft.ContainerInstance* provider should report as *Registered*, as shown in the following example output:

```
Namespace                    RegistrationState
---------------------------  -------------------
Microsoft.ContainerInstance  Registered
```

If the provider shows as *NotRegistered*, register the provider using the `az provider register` as shown in the following example:

```bash
az provider register --namespace Microsoft.ContainerInstance
```

{% endcollapsible %}

#### Create the new AKS Cluster

{% collapsible %}

Set the SUBNET variable to the one created above.

```bash
SUBNET=$(az network vnet subnet show --resource-group <resource-group> --vnet-name myVnet --name myAKSSubnet --query id -o tsv)
```

Create the cluster. Replace the name with a new, unique name.

> Note: You may need to validate the variables below to ensure they are all set properly.

```bash
az aks create \
    --resource-group <resource-group> \
    --name <unique-aks-cluster-name> \
    --node-count 3 \
    --kubernetes-version $VERSION \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $SUBNET \
    --service-principal $APPID \
    --client-secret $PASSWORD \
    --no-wait
```

Once completed, validate that your cluster is up and get your credentials to access the cluster.

```bash
az aks get-credentials -n <your-aks-cluster-name> -g <resource-group>
```

```bash
kubectl get nodes
```

{% endcollapsible %}

#### Enable virtual nodes

{% collapsible %}

Add Azure CLI extension.

```bash
az extension add --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl
```

Enable the virtual node in your cluster.

```bash
az aks enable-addons \
    --resource-group <resource-group> \
    --name <your-aks-cluster-name> \
    --addons virtual-node \
    --subnet-name myVirtualNodeSubnet
```

Verify the node is available.

```bash
kubectl get node

NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-30482081-0   Ready    agent   30m   v1.11.5
aks-nodepool1-30482081-1   Ready    agent   30m   v1.11.5
aks-nodepool1-30482081-2   Ready    agent   30m   v1.11.5
virtual-node-aci-linux     Ready    agent   11m   v1.13.1-vk-v0.7.4-44-g4f3bd20e-dev
```

{% endcollapsible %}

#### Deploy MongoDB and the Capture Order API on the new cluster

Repeat the steps in the [Deploy MongoDB](#db) to deploy the database on your new cluster.
Repeat the steps in the [Deploy Order Capture API](#api) to deploy the API on your new cluster on traditional nodes.

#### Create a new Capture Order API deployment targeting the virtual node

{% collapsible %}

Save the YAML below as `captureorder-deployment-aci.yaml` or download it from [captureorder-deployment-aci.yaml](yaml-solutions/advanced/captureorder-deployment-aci.yaml)

Be sure to replace to environment variables in the yaml to match your environment:
* TEAMNAME
* CHALLENGEAPPINSIGHTS_KEY
* MONGOHOST
* MONGOUSER
* MONGOPASSWORD

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: captureorder-aci
spec:
  selector:
      matchLabels:
        app: captureorder
  template:
      metadata:
        labels:
            app: captureorder
      spec:
        containers:
        - name: captureorder
          image: azch/captureorder
          imagePullPolicy: Always
          env:
          - name: TEAMNAME
            value: "team-azch"
          #- name: CHALLENGEAPPINSIGHTS_KEY # uncomment and set value only if you've been provided a key
          #  value: "" # uncomment and set value only if you've been provided a key
          - name: MONGOHOST
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoHost
          - name: MONGOUSER
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoUser
          - name: MONGOPASSWORD
            valueFrom:
              secretKeyRef:
                name: mongodb
                key: mongoPassword
          ports:
          - containerPort: 8080
        nodeSelector:
          kubernetes.io/role: agent
          beta.kubernetes.io/os: linux
          type: virtual-kubelet
        tolerations:
        - key: virtual-kubelet.io/provider
          operator: Exists
        - key: azure.com/aci
          effect: NoSchedule
```

Deploy it.

```bash
kubectl apply -f captureorder-deployment-aci.yaml
```

> **Note** the added `nodeSelector` and `tolerations` sections that basically tell Kubernetes that this deployment will run on the Virtual Node on Azure Container Instances (ACI).

{% endcollapsible %}


#### Validate ACI instances

{% collapsible %}

You can browse in the Azure Portal and find your Azure Container Instances deployed.


You can also see them in your AKS cluster:

```bash
kubectl get pod -l app=captureorder

NAME                                READY   STATUS    RESTARTS   AGE
captureorder-5cbbcdfb97-wc5vd       1/1     Running   1          7m
captureorder-aci-5cbbcdfb97-tvgtp   1/1     Running   1          2m
```

You can scale each deployment up/down and validate each are functioning.

```bash
kubectl scale deployment captureorder --replicas=0

kubectl scale deployment captureorder-aci --replicas=5
```

Test the endpoint.

```bash
curl -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -X POST http://[Your Service Public LoadBalancer IP]/v1/order
```

{% endcollapsible %}