---
sectionid: terraform-iaac
sectionclass: h2
parent-id: devops
title: DevOps - Terraform
---

Deploying the Azure Infrastructure and the container workload may seem like two different problems, but they are both infrastructure deployment concerns. Wouldn't it be great to be able to use one tool to recreate the entire environment?

Learn more about Terraform by going to <https://www.terraform.io/intro/index.html>

### Tasks

#### Use Terraform to deploy AKS

{% collapsible %}
You can follow the guide on <https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks>
{% endcollapsible %}

#### Deploy a Helm chart to new AKS cluster

{% collapsible %}
Once you have the AKS cluster deployed, you can also use Terraform to deploy Helm charts <https://www.terraform.io/docs/providers/helm/index.html>

> **Hint** Create a seperate folder for this Terraform code. Terraform treats each folder entirely seperate, and this should simplify dependancies.

{% endcollapsible %}