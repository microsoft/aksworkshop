---
sectionclass: h2
sectionid: acs
parent-id: advanced
title: Deploy a private Kubernetes cluster with Azure Container Service (ACS-engine) 
---

Despite the API being secured using client certificates and TLS your organisation has a security policy that prevents the Kubernetes API from being offered on a public IP address. 
Ensure that your Kubernetes clusters do not have their API published on a public IP address by deploying a new cluster in an isolated network. 
Also, for higher security, we will deploy the production cluster with RBAC enabled. ACS-engine enables RBAC, by default.  
Finally, ACS-engine enables Azure container networking plugin (CNI), which might be useful later on, to apply network policies between the apps. 
 
1. Create an ACS Engine cluster definition specifying a private Kubernetes API
2. Provision a Kubernetes cluster using ACS Engine
3. Deploy the application 

**Resources:**
- <https://github.com/Azure/acs-engine/blob/master/docs/kubernetes/features.md#private-cluster>