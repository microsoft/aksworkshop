---
sectionid: prereq
sectionclass: h2
title: Prerequisites
parent-id: intro
---
### Open Text Editor

There are a number of values that you will be provided or you will create along the way that you will need later on in the lab. For your convenience, we list the most relevant here. It's recommended that you copy this list to a text editor and update the values as you go along. That way, it will be easy to copy them from the text editor when you need them, and especially if you lose your Azure Cloud Shell connection during the lab.

```sh
Azure Credentials:

Username:	<Sent in email, and available on lab environment details page>
Password:	<Sent in email, and available on lab environment details page>

Others:

Application ID (Service Pincipal):		<Sent in email, and available on lab environment details page>

Application Secret Key (Client Secret):	<Sent in email, and available on lab environment details page>

Region: 								<Location value of "az group list" command output>

Resource Group: 						<Name value of "az group list" command output>

Cluster Name: 							<Specified when creating cluster>

MongoDB Username: 						orders-user

MongoDB Password: 						orders-password

MongoDB DNS Name: 						orders-mongo-mongodb.default.svc.cluster.local

Capture Order IP Address: 				<External IP value of "kubectl get svc captureorder" command output> 

Ingress IP Address: 					<External IP value of "kubectl get svc -n ingress ingress-nginx-ingress-controller" command output> 

Azure Container Registry Name: 			<Specified when creating registry> 

Build ID: 								<Run ID from "az acr build" command> 

Aqua Admin Username: 					administrator

Aqua Admin Password: 					<Specified when deploying Aqua>

Aqua Server IP: 						<From output of Aqua deployment; or external IP value of "kubectl get svc aqua-web -n aqua" command output> 

Aqua Server URL: 						http://<Aqua Server IP>:8080
```

### Access Azure Cloud Shell

For this lab, we will use the lab subscription that was provided and Azure Cloud Shell.

{% collapsible %}

Head over to <https://shell.azure.com>, and sign in with your Azure Subscription details. Note, if you're already an Azure user, you may need to sign out of another subscription before using the subscription provided for the lab.

Select **Bash** as your shell.

![Select Bash](media/cloudshell/0-bash.png)

Select **Show advanced settings**

![Select show advanced settings](media/cloudshell/1-mountstorage-advanced.png)

Set the **Storage account** and **File share** names to your resource group name (all lowercase, without any special characters), then hit **Create storage**

![Azure Cloud Shell](media/cloudshell/2-storageaccount-fileshare.png)

You should now have access to the Azure Cloud Shell

![Set the storage account and fileshare names](media/cloudshell/3-cloudshell.png)

{% endcollapsible %}

#### Tips for uploading and editing files in Azure Cloud Shell

- You can use `code <file you want to edit>` in Azure Cloud Shell to open the built-in text editor.
- You can upload files to the Azure Cloud Shell by dragging and dropping them
- You can also do a `curl -o filename.ext https://file-url/filename.ext` to download a file from the internet.
