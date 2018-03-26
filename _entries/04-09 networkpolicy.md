---
sectionid: networkpolicy
sectionclass: h2
parent-id: advanced
title: Advanced - Network Policy
---

*This is a new challenge utlilising a new feature in ACS Engine. Only attempt should you wish to investigate this feature.*

Your network infrastructure team is concerned about the fact that all containers can cross communicate together. They have asked you to restrict network communication between the **Order Capture** containers and the **Fulfill Order** containers; they shouldn't be allowed to communicate together.

You may also try using **kube-router** with AKS <https://github.com/cloudnativelabs/kube-router/blob/master/Documentation/README.md>

**Resources:**
- <https://github.com/Azure/acs-engine/tree/master/examples/networkpolicy>
- <https://github.com/Azure/azure-container-networking/blob/master/docs/network.md>
- <https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-nsg?wt.mc_id=CSE_(606698)>
- <https://docs.projectcalico.org/v2.0/getting-started/kubernetes/>