---
sectionid: abtesting
sectionclass: h2
parent-id: advanced
title: Advanced - A/B testing and canary deployments

---

Your organization wants to deploy multiple versions of the application side-by-side to do A/B testing and canary deployments. There are a couple of approaches to achieve this (Istio, Traefik, ..).

For this challenge, you may switch to using the Go version of the Order Capture API. You'll find the images and code below.

**Order Capture API (Go)**
- Docker Image: <https://hub.docker.com/r/sabbour/captureorderack/>
- GitHub Repo: <https://github.com/sabbour/captureorderack/tree/master/golang/>

**Hint:** Make sure that you don't disrupt your orders while deploying, verify performance and be prepared to rollback if needed. If you are using your own Application Insights, you'll find telemetry from the .NET Core version tagged with _Role Name_ **captureorder_netcore** and telemetry from the Go version tagged with **captureorder_golang**.

![](media/rolenametag.png)

 
**Resources:**
- <https://docs.microsoft.com/en-us/azure/application-insights?wt.mc_id=CSE_(606698)>
- <https://kubernetes.io/docs/concepts/cluster-administration/manage-deployment/#canary-deployments>
- <https://istio.io/docs/concepts/traffic-management/request-routing.html>
- <https://github.com/ContainerSolutions/k8s-deployment-strategies/tree/master/ab-testing>