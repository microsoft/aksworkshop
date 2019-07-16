---
sectionid: tls
sectionclass: h2
title: Enable SSL/TLS on ingress
parent-id: upandrunning
---

You want to enable connecting to the frontend website over SSL/TLS. In this task, you'll use [Let's Encrypt](https://letsencrypt.org/) free service to generate valid SSL certificates for your domains, and you'll integrate the certificate issuance workflow into Kubernetes.

> **Important** After you finish this task for the `frontend`, you may either receive some browser warnings about "mixed content" or the orders might not load at all because the calls happen via JavaScript. Use the same concepts to create an ingress for `captureorder` service and use SSL/TLS to secure it in order to fix this.

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

#### Update the ingress resource to automatically request a certificate

Issuing certificates can be done automatically by properly annotating the ingress resource.

{% collapsible %}

Save the YAML below as `frontend-ingress-tls.yaml` or download it from [frontend-ingress-tls.yaml](yaml-solutions/advanced/frontend-ingress-tls.yaml).

> **Note** Make sure to replace `_INGRESS_CONTROLLER_EXTERNAL_IP_` with your cluster ingress controller external IP. Also make note of the `secretName: frontend-tls-secret` as this is where the issued certificate will be stored as a Kubernetes secret.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt
spec:
  tls:
  - hosts:
    - frontend._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io
    secretName: frontend-tls-secret
  rules:
  - host: frontend._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io
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
        frontend.52.255.217.198.nip.io
      Http 01:
        Ingress Class:  addon-http-application-routing
  Dns Names:
    frontend.52.255.217.198.nip.io
  Issuer Ref:
    Kind:       ClusterIssuer
    Name:       letsencrypt
  Secret Name:  frontend-tls-secret
```

Verify that the frontend is accessible over HTTPS and that the certificate is valid.

![Let's Encrypt SSL certificate](media/ssl-certificate.png)

Note: even if the certificate is valid, you may still get a warning in your browser because of the unsafe cross-scripting.


{% endcollapsible %}

> **Resources**
> - [https://github.com/helm/charts/tree/master/stable/mongodb#replication](https://github.com/helm/charts/tree/master/stable/mongodb#replication)