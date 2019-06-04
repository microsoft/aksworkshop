---

sectionid: api
sectionclass: h2
parent-id: upandrunning
title: Deploy the colors application
---

We're going to deploy and expose our color-coded application which requires an external endpoint exposed on port 80. 

### Environmental variables
The color application takes an environmental variable to define the color that will be displayed. 
  * `COLOR=[color code, hex, or name]`

### Tasks

#### Provision color-coded app

##### Deployment

Save the YAML below as `blue.deployment.yaml`

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: colors
  name: colors
spec:
  replicas: 3
  selector:
    matchLabels:
      app: "colors"
  template:
    metadata:
      labels:
        app: colors
    spec:
      containers:
      - env:
        - name: COLOR
          value: '#44B3C2'
        image: containers101/color-coded:master
        imagePullPolicy: Always
        name: colors
        ports:
        - containerPort: 8080
          protocol: TCP
```

Deploy the capture order application using `kubectl apply`

```sh
kubectl apply -f blue.deployment.yaml
```

#### Verify the pods are up and running

```sh
kubectl get deployments
```

This should show the colors deployment with three pods available and up-to-date. 

#### Service

Kubernetes uses services to expose and loadbalance deployments. 

Save the yaml below as `blue.svc.yaml`.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: colors
spec:
  type: LoadBalancer
  selector:
    app: colors
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

Now create the service with `kubectl`
```sh
kubectl apply -f blue.svc.yaml
```

Because we used `LoadBalancer` for our service type, AKS will provision an external ip address we can use to access our application. You retrieve this ip address with this command:

```sh
kubectl get service colors
```

Provisioning an external ip can take a minute or two but once it does loads under the `EXTERNAL-IP` column you can open that ip in your browser to see the application. 

#### Watch Kubernetes keep your app running

The colors app is special because when you open it in your browser and click anywhere it causes the pod to die. This is great for demostrating how AKS handles failover between pods and restarts. The best way to see this in action is to open two browser windows side by side. One with your app, and one with our Azure cloud shell. 

In your cloud shell use this command to watch the status of your running pods
```sh
watch ubectl get pods -l app=colors
```
>  **Hint**
>  To get out of a watch, use `ctrl-c`

Then, with your browser, click anywhere and watch the pod die and be restarted in your cloud window. Click back on your browser to get back to your running application. 

Everytime you kill a pod, Kubernetes will wait longer and longer between pod restarts.

> **Resources**
>
> * <https://kubernetes.io/docs/concepts/workloads/controllers/deployment/>
> * <https://kubernetes.io/docs/concepts/services-networking/service/>
