---
sectionid: networkpolicy
sectionclass: h2
parent-id: advanced
title: Advanced - Network Policy
---

Your network infrastructure team is concerned about the fact that all containers can cross communicate together. They have asked you to restrict network communication between the **Order Capture** containers and the **Fulfill Order** containers; they shouldn't be allowed to communicate together.

You may also try using **kube-router** with AKS <https://github.com/cloudnativelabs/kube-router/blob/master/Documentation/README.md>

> **Resources**
> * <https://github.com/cloudnativelabs/kube-router>
> * <https://carlos.mendible.com/2018/07/19/at-last-network-policies-in-aks-with-kube-router/>