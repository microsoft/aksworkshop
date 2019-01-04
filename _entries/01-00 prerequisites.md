---

sectionclass: h2
title: Prerequisites
parent-id: intro
---

### Tools

If you're intending to run the tasks on your personal machine, you'll need to install the tools below:

| Tool | URL     |
|------|---------|
| Azure CLI    | <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest> |
| Docker       | <https://docs.docker.com/install/#supported-platforms>        |

You can also opt to use the Azure Cloud Shell accessible at <https://shell.azure.com> once you login with an Azure subscription.

### Azure subscription

#### If you have an Azure subscription

Please use your username and password to login to <https://portal.azure.com>.

Also please authenticate your Azure CLI by running the command below on your machine and following the instructions.

```sh
az login
```

#### If you have been given an access to a subscription as part of a lab, or you already have a Service Principal you want to use

If you have lab environment credentials similar to the below or you already have a Service Principal you will use with this workshop,

![media/lab-env.png]

Please then perform an `az login` on your machine using the command below, passing in the `Application Id`, the `Application Secret Key` and the `Tenant Id`.

```sh
az login --service-principal --username APP_ID --password "APP_SECRET" --tenant TENANT_ID
```