---
sectionid: tls
sectionclass: h2
title: Enable SSL/TLS on ingress
parent-id: upandrunning
---

You want to enable connecting to the frontend website over SSL/TLS. In this task, you'll use [Let's Encrypt](https://letsencrypt.org/) free service to generate valid SSL certificates for your domains, and you'll integrate the certificate issuance workflow into Kubernetes.

### Tasks

#### Install `cert-manager`

[cert-manager](https://github.com/jetstack/cert-manager) is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources. It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

{% collapsible %}

Install **cert-manager** using Helm and configure it to use `letsencrypt` as the certificate issuer.

```sh
helm install stable/cert-manager --name cert-manager --set ingressShim.defaultIssuerName=letsencrypt --set ingressShim.defaultIssuerKind=ClusterIssuer --version v0.5.2
```

{% endcollapsible %}

#### Create a Let's Encrypt ClusterIssuer

In order to begin issuing certificates, you will need to set up a ClusterIssuer.

{% collapsible %}

Save the YAML below as `letsencrypt-clusterissuer.yaml` or download it from [letsencrypt-clusterissuer.yaml](yaml-solutions/advanced/letsencrypt-clusterissuer.yaml).

> **Note** Make sure to replace `_YOUR_EMAIL_` with your email.

```yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory # production
    #server: https://acme-staging-v02.api.letsencrypt.org/directory # staging
    email: _YOUR_EMAIL_ # replace this with your email
    privateKeySecretRef:
      name: letsencrypt
    http01: {}
```

And apply it using

```sh
kubectl apply -f letsencrypt-clusterissuer.yaml
```

{% endcollapsible %}

#### Issue a certificate for the frontend domain

Issuing certificates happens through creating Certificate objects.

{% collapsible %}

Save the YAML below as `frontend-certificate.yaml` or download it from [frontend-certificate.yaml](yaml-solutions/advanced/frontend-certificate.yaml).

> **Note** Make sure to replace `_CLUSTER_SPECIFIC_DNS_ZONE_` with your cluster HTTP Routing add-on DNS Zone name. Also make note of the `secretName: frontend-tls-secret` as this is where the issued certificate will be stored as a Kubernetes secret. You'll need this in the next step.

```yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: frontend
spec:
  secretName: frontend-tls-secret
  issuerRef:
    name: letsencrypt
    kind: ClusterIssuer
  dnsNames:
  - frontend._CLUSTER_SPECIFIC_DNS_ZONE_ # replace cluster specific dns zone with your HTTP Routing DNS Zone name
  acme:
    config:
    - http01:
        ingressClass: addon-http-application-routing
      domains:
      - frontend._CLUSTER_SPECIFIC_DNS_ZONE_  # replace cluster specific dns zone with your HTTP Routing DNS Zone name
```

And apply it using

```sh
kubectl apply -f frontend-certificate.yaml
```

{% endcollapsible %}

#### Update the frontend Ingress with a TLS rule

Update the existing Ingress rule for the frontend deployment with the annotation `kubernetes.io/tls-acme: 'true'` as well as adding a `tls` section pointing at Secret name where the certificate created earlier is stored.

{% collapsible %}

Save the YAML below as `frontend-ingress-tls.yaml` or download it from [frontend-ingress-tls.yaml](yaml-solutions/advanced/frontend-ingress-tls.yaml).

> **Note** Make sure to replace `_CLUSTER_SPECIFIC_DNS_ZONE_` with your cluster HTTP Routing add-on DNS Zone name.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: addon-http-application-routing
    kubernetes.io/tls-acme: 'true' # enable TLS
spec:
  tls:
  - hosts:
    - frontend._CLUSTER_SPECIFIC_DNS_ZONE_ # replace cluster specific dns zone with your HTTP Routing DNS Zone name
    secretName: frontend-tls-secret
  rules:
  - host: frontend._CLUSTER_SPECIFIC_DNS_ZONE_ # replace cluster specific dns zone with your HTTP Routing DNS Zone name
    http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
        path: /
```

And apply it using

```sh
kubectl apply -f frontend-ingress-tls.yaml
```

{% endcollapsible %}

#### Verify the certificate is issued and test the website over SSL

{% collapsible %}

Let's Encrypt should automatically verify the hostname in a few seconds. Make sure that the certificate has been issued by running:

```sh
kubectl describe certificate frontend
```

You should get back something like:

```sh
Name:         frontend
Namespace:    default
Labels:       <none>
Annotations:  kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"certmanager.k8s.io/v1alpha1","kind":"Certificate","metadata":{"annotations":{},"name":"frontend","namespace":"default"},"sp...
API Version:  certmanager.k8s.io/v1alpha1
Kind:         Certificate
Metadata:
  Creation Timestamp:  2019-02-13T02:40:40Z
  Generation:          1
  Resource Version:    11448
  Self Link:           /apis/certmanager.k8s.io/v1alpha1/namespaces/default/certificates/frontend
  UID:                 c0a620ee-2f38-11e9-adae-0a58ac1f1147
Spec:
  Acme:
    Config:
      Domains:
        frontend.b3ec7d3966874de389ba.eastus.aksapp.io
      Http 01:
        Ingress Class:  addon-http-application-routing
  Dns Names:
    frontend.b3ec7d3966874de389ba.eastus.aksapp.io
  Issuer Ref:
    Kind:       ClusterIssuer
    Name:       letsencrypt
  Secret Name:  frontend-tls-secret
```

Verify that the frontend is accessible over HTTPS and that the certificate is valid.

![Let's Encrypt SSL certificate](media/ssl-certificate.png)

> **Important** Because the `captureorder` service is deployed over HTTP, you may receive some browser warnings about "mixed content" or the orders might not load at all because the calls happen via JavaScript. Use the same concepts to create an ingress for `captureorder` service and use SSL/TLS to secure it.

{% endcollapsible %}

> **Resources**
> - [https://github.com/helm/charts/tree/master/stable/mongodb#replication](https://github.com/helm/charts/tree/master/stable/mongodb#replication)