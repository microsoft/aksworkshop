---
sectionid: azurekeyvault-flexvolumeplugin
sectionclass: h2
parent-id: advancedclustersetup
title: Use Azure Key Vault for secrets
---

Kubernetes provides a primitive, [secrets](https://kubernetes.io/docs/concepts/configuration/secret/), which can be used to store sensitive information and later retrieve them as an environment variable or a mounted volume into memory. If you have tighter security requirements that Kubernetes secrets don't quite meet yet, for example you want an audit trail of all interactions with the keys, or version control, or FIPs compliance, you'll need to use an external key vault.

There are a couple of options to accomplish this including [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) and [HashiCorp Vault](https://www.vaultproject.io/). In this task, you'll use Azure Key Vault to store the MongoDB password.

The `captureorder` application can be configured to read the MongoDB password from either an environment variable or from the file system. This task is focused on configuring the `captureorder` container running in AKS to read the MongoDB password from a secret stored in Azure Key Vault using the [Kubernetes FlexVolume plugin for Azure Key Vault](https://github.com/Azure/kubernetes-keyvault-flexvol).

Key Vault FlexVolume for Azure allows you to mount multiple secrets, keys, and certs stored in Azure Key Vault into pods as an in memory volume. Once the volume is attached, the data in it is mounted into the container's file system in `tmpfs`.

### Tasks

#### Create an Azure Key Vault

{% collapsible %}

Azure Key Vault names are unique. Replace `<unique keyvault name>` with a unique name between 3 and 24 characters long.
```bash
az keyvault create --resource-group <resource-group> --name <unique keyvault name>
```

{% endcollapsible %}

#### Store the MongoDB password as a secret

{% collapsible %}

Replace `orders-password` with the password for MongoDB.

```bash
az keyvault secret set --vault-name <unique keyvault name> --name mongo-password --value "orders-password"
```

{% endcollapsible %}

#### Create Service Principal to access Azure Key Vault

The Key Vault FlexVolume driver offers two modes for accessing a Key Vault instance: Service Principal and Pod Identity. In this task, we'll create a Service Principal that the driver will use to access the Azure Key Vault instance.

{% collapsible %}

Replace `<name>` with a service principal name that is unique in your organization.

```bash
az ad sp create-for-rbac --name "http://<name>" --skip-assignment
```

You should get back something like the below, make note of the `appId` and `password`.

```json
{
  "appId": "9xxxxxb-bxxf-xx4x-bxxx-1xxxx850xxxe",
  "displayName": "<name>",
  "name": "http://<name>",
  "password": "dxxxxxx9-xxxx-4xxx-bxxx-xxxxe1xxxx",
  "tenant": "7xxxxxf-8xx1-41af-xxxb-xx7cxxxxxx7"
}
```

{% endcollapsible %}

#### Ensure the Service Principal has all the required permissions to access secrets in your Key Vault instance

{% collapsible %}

Retrieve your Azure Key Vault ID and store it in a variable `KEYVAULT_ID`,  replacing `<unique keyvault name>` with your Azure Key Vault name.

```sh
KEYVAULT_ID=$(az keyvault show --name <unique keyvault name> --query id --output tsv)
```

Create the role assignment, replacing `"http://<name>"` with your service principal name that was created earlier, for example `"http://sp-captureorder"`.

```sh
az role assignment create --role Reader --assignee "http://<name>" --scope $KEYVAULT_ID
```

{% endcollapsible %}

#### Configure Azure Key Vault to allow access to secrets using the Service Principal you created

{% collapsible %}

Apply the policy on the Azure Key Vault, replacing the `<unique keyvault name>` with your Azure Key Vault name, and `<appId>` with the appId above.

```sh
az keyvault set-policy -n <unique keyvault name> --secret-permissions get --spn <appId>
```

{% endcollapsible %}

#### Create a Kubernetes secret to store the Service Principal created earlier

{% collapsible %}

Add your service principal credentials as a Kubernetes secrets accessible by the Key Vault FlexVolume driver. Replace the `<appId>` and `<password>` with the values you got above.

```sh
kubectl create secret generic kvcreds --from-literal clientid=<appId> --from-literal clientsecret=<password> --type=azure/kv
```

{% endcollapsible %}

#### Deploy Key Vault FlexVolume for Kubernetes into your AKS cluster

{% collapsible %}

Install the KeyVault FlexVolume driver

```sh
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml
```

To validate the installer is running as expected, run the following commands:

```bash
kubectl get pods -n kv
```

You should see the keyvault flexvolume pods running on each agent node:

```bash
keyvault-flexvolume-f7bx8   1/1       Running   0          3m
keyvault-flexvolume-rcxbl   1/1       Running   0          3m
keyvault-flexvolume-z6jm6   1/1       Running   0          3m
```

{% endcollapsible %}

#### Retrieve the Azure subscription/tenant ID where the Azure Key Vault is deployed

You'll need both to configure the Key Vault FlexVolume driver in the next step.

{% collapsible %}

Retrieve your Azure subscription ID and keep it.

```sh
az account show --query id --output tsv
```

Retrieve your Azure tenant ID and keep it.

```sh
az account show --query tenantId --output tsv
```

{% endcollapsible %}

#### Modify the `captureorder` deployment to read the secret from the FlexVolume

The `captureorder` application can read the MongoDB password from an environment variable `MONGOPASSWORD` or from a file on disk at `/kvmnt/mongo-password` if the environment variable is not set (see [code](https://github.com/Azure/azch-captureorder/blob/4ee591d3ceb2d0914deb73c3ec31c26ffce19884/models/order.go#L261) if you're interested).

In this task, you're going to modify the `captureorder` deployment manifest to remove the `MONGOPASSWORD` environment variable and add the FlexVol configuration.

{% collapsible %}

Edit your `captureorder-deployment.yaml` by **removing** the `MONGOPASSWORD` from the `env:` section of the environment variables.

```yaml
- name: MONGOPASSWORD
  valueFrom:
    secretKeyRef:
      name: mongodb
      key: mongoPassword
```

Add the below `volumes` definition to the configuration, which defines a FlexVolume called `mongosecret` using the Azure Key Vault driver. The driver will look for a Kubernetes secret called `kvcreds` which you created in an earlier step in order to authenticate to Azure Key Vault.

```yaml
volumes:
  - name: mongosecret
    flexVolume:
      driver: "azure/kv"
      secretRef:
        name: kvcreds
      options:
        usepodidentity: "false"
        keyvaultname: <unique keyvault name>
        keyvaultobjectnames: mongo-password # Name of Key Vault secret
        keyvaultobjecttypes: secret
        resourcegroup: <kv resource group>
        subscriptionid: <kv azure subscription id>
        tenantid: <kv azure tenant id>
```

Mount the `mongosecret` volume to the pod at `/kvmnt`

```yaml
volumeMounts:
  - name: mongosecret
    mountPath: /kvmnt
    readOnly: true
```

You'll need to replace the placeholders with the values mapping to your configuration.

The final deployment file should look like so. Save the YAML below as `captureorder-deployment-flexvol.yaml` or download it from [captureorder-deployment-flexvol.yaml](yaml-solutions/advanced/captureorder-deployment-flexvol.yaml). Make sure to replace the placeholders with values for your configuration.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: captureorder
spec:
  selector:
      matchLabels:
        app: captureorder
  replicas: 2
  template:
      metadata:
        labels:
            app: captureorder
      spec:
        containers:
        - name: captureorder
          image: azch/captureorder
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              port: 8080
              path: /healthz
          livenessProbe:
            httpGet:
              port: 8080
              path: /healthz
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
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
          ports:
          - containerPort: 8080
          volumeMounts:
          - name: mongosecret
            mountPath: /kvmnt
            readOnly: true
        volumes:
        - name: mongosecret
          flexVolume:
            driver: "azure/kv"
            secretRef:
              name: kvcreds
            options:
              usepodidentity: "false"
              keyvaultname: <unique keyvault name>
              keyvaultobjectnames: mongo-password # Name of Key Vault secret
              keyvaultobjecttypes: secret
              keyvaultobjectversions: ""     # [OPTIONAL] list of KeyVault object versions (semi-colon separated), will get latest if empty
              resourcegroup: <kv resource group>
              subscriptionid: <kv azure subscription id>
              tenantid: <kv azure tenant id>
```

And deploy it using

```sh
kubectl apply -f captureorder-deployment-flexvol.yaml
```

Apply your changes.

{% endcollapsible %}

#### Verify that everything is working

Once you apply the configuration, validate that the capture order pod loaded the secret from Azure Key Vault and that you can still process orders. You can also exec into one of the `captureorder` pods and verify that the MongoDB password has been mounted at `/kvmnt/mongo-password`

{% collapsible %}

```sh
# Get the pod name.
kubectl get pod -l app=captureorder

# Exec into the pod and view the mounted secret.
kubectl exec <podname> cat /kvmnt/mongo-password
```

The last command will return `"orders-password"`.

{% endcollapsible %}

> **Resources**
> - [https://kubernetes.io/docs/concepts/storage/volumes/](https://kubernetes.io/docs/concepts/storage/volumes/)
> - [https://github.com/kubernetes/community/blob/master/contributors/devel/sig-storage/flexvolume.md](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-storage/flexvolume.md)