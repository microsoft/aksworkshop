---
sectionid: prereq
sectionclass: h2
title: Prerequisites
parent-id: intro
---

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
