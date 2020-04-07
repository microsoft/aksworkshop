---
sectionid: tls
sectionclass: h2
title: Enable TLS (SSL) on ingress
parent-id: upandrunning
---

You want to enable secure connections to the Frontend website over TLS (SSL). In this task, you'll use [Let's Encrypt](https://letsencrypt.org/)'s free service to generate valid TLS certificates for your domains, and you'll integrate the certificate issuance workflow into Kubernetes.

### Tasks

#### Install `cert-manager`

[cert-manager](https://github.com/jetstack/cert-manager) is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources. It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

**Task Hints**
* As with MongoDB and NGINX use Helm to deploy cert-manager. You need to do a little more than just `helm install`, however the [steps are documented in the GitHub repo for the cert-manager chart](https://github.com/helm/charts/tree/master/stable/cert-manager#installing-the-chart)
* It's recommended to install the chart into a different/name namespace

{% collapsible %}

Install **cert-manager** using Helm and configure it to use `letsencrypt` as the certificate issuer.

```sh
# Install the CustomResourceDefinition resources separately
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml

# Create the namespace for cert-manager
kubectl create namespace cert-manager

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm install cert-manager \
  --namespace cert-manager \
  jetstack/cert-manager
```

{% endcollapsible %}

#### Create a Let's Encrypt ClusterIssuer

In order to begin issuing certificates, you will need to set up a `ClusterIssuer`.

**Task Hints**
* cert-manager uses a custom Kubernetes object called an **Issuer** or **ClusterIssuer** to act as the interface between you and the certificate issuing service (in our case Let's Encrypt). There are many ways to create an issuer, but [the cert-manager docs provides a working example YAML for Let's Encrypt](https://cert-manager.readthedocs.io/en/latest/reference/issuers.html#issuers). It will require some small modifications, **You must change the type to `ClusterIssuer` or it will not work**. The recommendation is you call the issuer `letsencrypt`
* Check the status with `kubectl describe clusterissuer.cert-manager.io/letsencrypt` (or other name if you didn't call your issuer `letsencrypt`)

{% collapsible %}

Save the YAML below as `letsencrypt-clusterissuer.yaml` or download it from [letsencrypt-clusterissuer.yaml](yaml-solutions/advanced/letsencrypt-clusterissuer.yaml).

> **Note** Make sure to replace `_YOUR_EMAIL_` with your email.

```yaml
apiVersion: cert-manager.io/v1alpha2
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
    solvers:
       - http01:
           ingress:
             class:  nginx
```

And apply it using

```sh
kubectl apply -f letsencrypt-clusterissuer.yaml
```

{% endcollapsible %}

#### Update the ingress resource to automatically request a certificate

Issuing certificates can be done automatically by properly annotating the ingress resource.

**Task Hints**
* You need to make changes to the frontend ingress, you can modify your existing frontend ingress YAML file or make a copy to a new name
* [The quick start guide for cert-manager provides guidance on the changes you need to make](https://cert-manager.readthedocs.io/en/latest/tutorials/acme/quick-start/index.html#step-7-deploy-a-tls-ingress-resource). Note the following:
  * The annotation `cert-manager.io/issuer: "letsencrypt-staging"` in the metadata, you want that to refer to your issuer `letsencrypt` and use cluster-issuer rather than issuer, e.g. `cert-manager.io/cluster-issuer: "letsencrypt"`
  * The new `tls:` section, here the `host` field should match the host in your rules section, and the `secretName` can be anything you like, this will be the name of the certificate issued (see next step)
* Reapply your changed frontend ingress using `kubectl`

{% collapsible %}

Save the YAML below as `frontend-ingress-tls.yaml` or download it from [frontend-ingress-tls.yaml](yaml-solutions/advanced/frontend-ingress-tls.yaml).

> **Note** Make sure to replace `_INGRESS_CONTROLLER_EXTERNAL_IP_` with your cluster ingress controller external IP. Also make note of the `secretName: frontend-tls-secret` as this is where the issued certificate will be stored as a Kubernetes secret.

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt
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

**Task Hints**
* You can list custom objects such as certificates with regular `kubectl` commands, e.g. `kubectl get cert` and `kubectl describe cert`, use the describe command to validate the cert has been issued and is valid
* Access the front end in your browser as before, e.g. `http://frontend.{ingress-ip}.nip.io` you might be automatically redirected to the `https://` version, if not modify the URL to access using `https://`
* **You will probably see nothing in the Orders view, and some errors in the developer console (F12)**, to fix this you will need to do some work to make the Order Capture API accessible over HTTPS with TLS. See the next section for more details.
  
{% collapsible %}

Let's Encrypt should automatically verify the hostname in a few seconds. Make sure that the certificate has been issued by running:

```sh
kubectl describe certificate frontend
```

You should get back something like:

```sh
Name:         frontend-tls-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  cert-manager.io/v1alpha2
Kind:         Certificate
Metadata:
  Creation Timestamp:  2020-01-30T14:14:53Z
  Generation:          2
  Owner References:
    API Version:           extensions/v1beta1
    Block Owner Deletion:  true
    Controller:            true
    Kind:                  Ingress
    Name:                  frontend
    UID:                   069293aa-68a8-4d63-8093-9b82f018f985
  Resource Version:        326924
  Self Link:               /apis/cert-manager.io/v1alpha2/namespaces/default/certificates/frontend-tls-secret
  UID:                     acf4834f-5ad7-42da-b660-be0dfed7eae0
Spec:
  Dns Names:
    frontend.51.105.126.236.nip.io
  Issuer Ref:
    Group:      cert-manager.io
    Kind:       ClusterIssuer
    Name:       letsencrypt
  Secret Name:  frontend-tls-secret
Status:
  Conditions:
    Last Transition Time:  2020-01-30T14:19:32Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2020-04-29T13:19:31Z
Events:
  Type    Reason        Age    From          Message
  ----    ------        ----   ----          -------
  Normal  GeneratedKey  6m23s  cert-manager  Generated a new private key
  Normal  Requested     6m23s  cert-manager  Created new CertificateRequest resource "frontend-tls-secret-21669938"
  Normal  Requested     2m11s  cert-manager  Created new CertificateRequest resource "frontend-tls-secret-253990887"
  Normal  Issued        104s   cert-manager  Certificate issued successfully

```

Verify that the frontend is accessible over HTTPS and that the certificate is valid.

![Let's Encrypt SSL certificate](media/ssl-certificate.png)

Note: even if the certificate is valid, you may still get a warning in your browser because of the unsafe cross-site scripting.


{% endcollapsible %}

#### Enable TLS for the Order Capture API to fix the Frontend application

  You should have noticed that the Frontend application now appears to be broken as it displays the **Orders** title but no order details beneath. This is because the Order Capture API is still using an unsecured HTTP connection and your web browser is blocking this unsafe content. To fix this, we need to enable TLS for the Order Capture API as well.

**Task Hints**
  * This is pretty much a repeat of the work you did when creating the Frontend ingress resource, so you just need to make a copy of the ingress YAML and configure it to direct traffic to the 'captureorder' service. 
  * You will need a new hostname, but it can still use the same Ingress Controller - for example `ordercapture.{ingress-ip}.nip.io`.
  * The web root of the Capture Order API returns a 404. During setup of the cert, LetsEncrypt may send a challenge to the address you specify for the Caputure Order API to ensure it's valid, but it will be expecting a 200 response. Therefore, you may need to configre the Ingress to redirect traffic from root `/` to a location that returns a response, such as `/v1/order`
  * Modify the `CAPTUREORDERSERVICEIP` environment variable in the Frontend deployment YAML. This now needs to refer to the hostname of your new `ordercapture` ingress instead of the IP address of the `ordercapture` service. You will need to redeploy the frontend to make the changes live.

{% collapsible %}

#### Create a new Kubernetes Ingress resource to direct traffic to the `captureorder` service

Save the YAML below as `captureorder-ingress-tls.yaml` or download it from [captureorder-ingress-tls.yaml](yaml-solutions/advanced/captureorder-ingress-tls.yaml).

> **Note** Make sure to replace `_INGRESS_CONTROLLER_EXTERNAL_IP_` with your cluster's ingress controller external IP.

```sh
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: captureorder
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt
    nginx.ingress.kubernetes.io/app-root: /v1/order
spec:
  tls:
  - hosts:
    - captureorder._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io
    secretName: captureorder-tls-secret
  rules:
  - host: captureorder._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io
    http:
      paths:
      - backend:
          serviceName: captureorder
          servicePort: 80
        path: /
```

You should now be able to query the `/v1/orders` endpoint or open the `/swagger` endpoint using HTTPS.

#### Update the Frontend deployment to use HTTPS to access the Capture Order API 

We need to redeploy the Frontend application so that it accesses the Capture Order API via the newly created Ingress

Save the YAML below as `frontend-deployment.yaml` or download it from [frontend-deployment.yaml](yaml-solutions/advanced/frontend-deployment.yaml).

> **Note** Make sure to replace `_INGRESS_CONTROLLER_EXTERNAL_IP_` with your cluster's ingress controller external IP.

```sh
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  selector:
      matchLabels:
        app: frontend
  replicas: 1
  template:
      metadata:
        labels:
            app: frontend
      spec:
        containers:
        - name: frontend
          image: azch/frontend
          imagePullPolicy: Always
          readinessProbe:
            httpGet:
              port: 8080
              path: /
          livenessProbe:
            httpGet:
              port: 8080
              path: /
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          env:
          - name: CAPTUREORDERSERVICEIP
            value: "captureorder._INGRESS_CONTROLLER_EXTERNAL_IP_.nip.io"
          ports:
          - containerPort: 8080
```

You should now be able to open the Frontend application and the order information should be displayed correctly.

{% endcollapsible %}

> **Resources**
> * <https://github.com/helm/charts/tree/master/stable/cert-manager>
> * <https://cert-manager.readthedocs.io/en/latest/reference/issuers.html>
> * <https://cert-manager.readthedocs.io/en/latest/tutorials/acme/quick-start>

### Architecture Diagram
Here's a high level diagram of the components you will have deployed when you've finished this section (click the picture to enlarge)

<a href="media/architecture/tls-certs.png" target="_blank"><img src="media/architecture/tls-certs.png" style="width:500px"></a>
