---

sectionid: db
sectionclass: h2
parent-id: upandrunning
title: Install Helm
---

To simplify application management in Kubernetes we're going to use Helm. Helm is a Kubernetes application package manager.

#### Install Helm on the AKS cluster

Tiller, the server-side component with which Helm communicates, needs to use a `ServiceAccount` to authenticate to your AKS cluster. For this lab, the `ServiceAccount` will have full cluster access:

Save the YAML below as `helm-rbac.yaml` or download it from [helm-rbac.yaml](yaml-solutions/01. challenge-02/helm-rbac.yaml)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

And create the `ServiceAccount` and RBAC roles using `kubectl apply`

```sh
kubectl apply -f helm-rbac.yaml
```

Use `helm init` to install Tiller

```sh
helm init --service-account tiller
```

Optional: To verify Helm has installed correctly use
```sh
helm version
```
This will show a server version which means Helm is up and running. 

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm>
