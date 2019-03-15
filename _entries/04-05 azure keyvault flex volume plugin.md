---
sectionid: azurekeyvault-flexvolumeplugin
sectionclass: h2
parent-id: advancedclustersetup
title: Pull MongoDB password from Azure Keyvault
---

In real practice, providing password, keys, certificates or credentials to application running in Kubernetes by hardcoding them into manifest files should never be done. Kubernetes provides a primitive, secrets, which can be used to store sensitive information and later retrieved in a manifest directly as an environment variable or mounted as a volume into memory. Kubernetes secrets are first base64 encoded then stored, like everything in Kuberenetes, as key/value entries into etcd. In AKS, etcd is encrypted at rest with Azure Storage Encryption. 

So now you are probally asking yourself "why would I need and external Key Vault as Kubernetes secrets seemingly do the trick?"

It is likely that your security team has tighter requirements on a key vault that Kubernetes secrets don't quite meet yet. Perhaps they want an audit trail of all interactions with the Keys, or version control, or FIPs compliance. If you find yourself answering these types of questions, it is likely that you need to use an external Key Vault. There are lots of great 3rd party Key Vaults to choose from, Hashicorp's Vault seems to be leading charge with features and user adoption rates. The downside of running Hashicorp's Vault, and there are not many, is that you take on the responsibility of managing the infrastructure required to run Vault. Azure Key Vault provides a PaaS Vault service with many of the same features as Hashicorps's Vault while removing the overhead of managing Infrastructure. 

This Challenge is focused on configuring the capture order application running in AKS to load your mongoDB password from a secret stored in Azure Key Vault. There are a few ways this can be achieved. First, you could use the Azure Key Vault <"Insert programming language"> SDK in the application code to load secrets at app runtime. Great option, but in this lab we are trying to keep application modification to a minimum. Second, you can use the Kubernetes FlexVolume plugin for Azure, more on that in a bit. And lastly, a Kubernetes Container Storage Interface (CSI) for Azure Key Vault was built by the Azure Container Upstream SDEs. However, CSI is a Kubernetes Alpha feature and the Azure Key Vault implementation requires a version of Kubernetes not yet available to AKS, >1.13. If you are interested in the differences between FlexVolumes and CSIs, give this article a read.
https://kubernetes.io/blog/2018/01/introducing-container-storage-interface/

The second option earlier mentioned, offers us a stable solution which requires minimal changes to you application to leverage. In fact, if your app can already load configurations from a file, it requires zero changes. Key Vault FlexVolume for Azure allows you to mount multiple secrets, keys, and certs stored in Key Management Systems into pods as an in memory volume. Once the Volume is attached, the data in it is mounted into the container's file system in tmpfs.

Find the Key Vault FlexVolume project here  https://github.com/Azure/kubernetes-keyvault-flexvol

### Tasks

#### Create an Azure KeyVault and Secret for MongoDB Password

{% collapsible %}

```bash
az keyvault create -n kv-aks-challenge -g <resource-group>
az keyvault secret set --vault-name kv-aks-challenge --name mongo-password --value "orders-password"
```

{% endcollapsible %}

#### Deploy Key Vault FlexVolume for Kubernetes into your AKS cluster

{% collapsible %}

Create a service principal that will be assigned to the AKS cluster in the template.
```bash
az ad sp create-for-rbac --name sp-captureorder --skip-assignment
```
**Note the appId and password.**

Add your service principal credentials as a Kubernetes secrets accessible by the KeyVault FlexVolume driver.
```bash
kubectl create secret generic kvcreds --from-literal clientid=<CLIENTID> --from-literal clientsecret=<CLIENTSECRET> --type=azure/kv
```

Ensure this service principal has all the required permissions to access secrets in your key vault instance. 
If not, you can run the following using the Azure cli:
```bash
# Assign Reader Role to the service principal for your keyvault
az role assignment create --role Reader --assignee <principalid> --scope /subscriptions/<subscriptionid>/resourcegroups/<resourcegroup>/providers/Microsoft.KeyVault/vaults/<keyvaultname>

az keyvault set-policy -n $KV_NAME --secret-permissions get --spn <YOUR SPN CLIENT ID>
```

Install the KeyVault Flexvolume
```bash
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml
```
To validate the installer is running as expected, run the following commands:

```bash
kubectl get pods -n kv
```

You should see the keyvault flexvolume installer pods running on each agent node:

```bash
keyvault-flexvolume-f7bx8   1/1       Running   0          3m
keyvault-flexvolume-rcxbl   1/1       Running   0          3m
keyvault-flexvolume-z6jm6   1/1       Running   0          3m
```
{% endcollapsible %}

#### Setup Helm Chart for ADO Build

{% collapsible %}

In Azure Devops Repos, relace the values files found in the captureorder chart created during the helm challenge content with the below yaml and be sure to edit the placeholders <>.

```yaml
minReplicaCount: 1
maxReplicaCount: 2
targetCPUUtilizationPercentage: 50
teamName: azch-team
appInsightKey: ""
mongoHost: "orders-mongo-mongodb.default.svc.cluster.local"
mongoUser: "orders-user"
mongoPassword: ""

image:
  repository: <unique-acr-name>.azurecr.io/captureorder
  tag: # Will be set at command runtime
  pullPolicy: Always
  
service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

flexVol:
  keyVaultName: <key-vault-name> # Name of keyvault containing mongo password secret
  keyVaultSecretName: mongo-password # Name of secret container mongo password
  keyVaultResourceGroup: <key-vault-resoure-group> # Name of resource group containing keyvault
  subscriptionId: <subscription ID> # target subscription id 
  tenantId: <tenant ID> # tenant ID of subscription 
```

Also replace the .../templates/deployment.yaml file contents with these.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "captureorder.fullname" . }}
  labels:
    app: {{ include "captureorder.name" . }}
    chart: {{ include "captureorder.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  selector:
      matchLabels:
        app: captureorder
  template:
      metadata:
        labels:
          app: {{ include "captureorder.name" . }}
          release: {{ .Release.Name }}
      spec:
        containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          readinessProbe:
            httpGet:
              port: 8080
              path: /healthz
          livenessProbe:
            httpGet:
              port: 8080
              path: /healthz
          resources:
{{ toYaml .Values.resources | indent 12 }}
          env:
          - name: TEAMNAME
            value: {{ .Values.teamName }}
          - name: MONGOHOST
            value: {{ .Values.mongoHost }}
          - name: MONGOUSER
            value: {{ .Values.mongoUser }}
          - name: MONGOPASSWORD
            value: {{ .Values.mongoPassword }}
          ports:
          - containerPort: 80
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
              keyvaultname: {{ .Values.flexVol.keyVaultName }}
              keyvaultobjectnames: {{ .Values.flexVol.keyVaultSecretName }}  # list of KeyVault object names (semi-colon separated)
              keyvaultobjecttypes: secret  # list of KeyVault object types: secret, key or cert (semi-colon separated)
              keyvaultobjectversions: ""     # [OPTIONAL] list of KeyVault object versions (semi-colon separated), will get latest if empty
              resourcegroup: {{ .Values.flexVol.keyVaultResourceGroup }}              # the resource group of the KeyVault
              subscriptionid: {{ .Values.flexVol.subscriptionId }}             # the subscription ID of the KeyVault
              tenantid: {{ .Values.flexVol.tenantId }} 
```

{% endcollapsible %}

#### Validate

Both of these edits should trigger a build and release in ADO. Once you are notified that the release was succesful, validate that the capture order pod loaded the secret for Azure Key Vault.

{% collapsible %}

```bash
#Get the pod name.
kubectl get po -l app=captureorder

#Exec into the pod and view the mounted secret.
kubectl exec <podname> cat /kvmnt/mongo-password
```
The last command will return "orders-password".

{% endcollapsible %}



