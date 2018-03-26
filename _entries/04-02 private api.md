---
sectionid: privateapi
sectionclass: h2
parent-id: advanced
title: Advanced - Deploy the Kubernetes API on a private IP address

---
*This is a new challenge utlilising a new feature in ACS Engine. Only attempt should you wish to investigate this feature.*

Despite the API being secured using client certificates and TLS your organisation has a security policy that prevents the Kubernetes API from being offered on a public IP address. Ensure that your Kubernetes clusters do not have their API published on a public IP address.
 
1. Build ACS Engine from the master branch (unless the feature has now been released)
2. Create an ACS Engine cluster definition specifying a private Kubernetes API
3. Provision a Kubernetes cluster using ACS Engine

**Resources:**
- <https://github.com/Azure/acs-engine/blob/master/docs/kubernetes/features.md#private-cluster>