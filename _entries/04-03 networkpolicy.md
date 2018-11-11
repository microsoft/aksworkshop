---
sectionid: networkpolicy
sectionclass: h2
parent-id: advanced
title: Advanced - Network Policy
---

Your network infrastructure team is concerned about the fact that all containers can cross communicate together.

### Tasks

* Restrict network communication between the **Order Capture** containers and the **Fulfill Order** containers; they shouldn't be allowed to communicate together.

> **Resources**
> * <https://github.com/cloudnativelabs/kube-router>
> * <https://www.kube-router.io/docs/>
> * <https://carlos.mendible.com/2018/07/19/at-last-network-policies-in-aks-with-kube-router/>