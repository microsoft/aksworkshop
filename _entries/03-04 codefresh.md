---
sectionid: codefresh
sectionclass: h2
parent-id: devops
title: Security scanning with Codefresh
---

As your application is growing and new libraries are being added, it is important to know of any security vulnerabilities before reaching production.

You will create a Codefresh pipeline that will use the Aqua Security platform you setup in the previous section for security scanning.

[Codefresh](https://codefresh.io/features/) is CI/CD solution for containers and Kubernetes/Helm. We will use the CI part in this section. Codefresh offers free accounts in the cloud, which are fully functional and can be connected with any git repository and any Kubernetes cluster.

> **Hint**
> - Make sure that you have ready the URL of your Aqua installation as well as your credentials
> - The Aqua scanner requires direct communication with the Docker daemon, and this is why in Codefresh, we manually mount the docker socket.
> - The Aqua scanner image is not public, and this is why we need to connect the Aqua registry to Codefresh 

### Tasks

#### Create a Codefresh account

{% collapsible %}

Content here 

{% endcollapsible %}

#### Integrate the Aqua Registry into Codefresh

#### Scan a public Docker image

#### Connect the Codefresh Registry to Aqua

#### Scan a private Docker image




> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
> * <https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>
> * [My docs](https://codefresh.io/docs/)
> * [My docs](https://codefresh.io/docs/)