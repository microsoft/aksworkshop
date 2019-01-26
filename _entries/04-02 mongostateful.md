---
sectionid: mongostateful
sectionclass: h2
title: MongoDB replication using a StatefulSet
parent-id: advancedclustersetup
---

Now that you scaled the replicas running the API, maybe it is time to scale MongoDB? If you used the typical command to deploy MongoDB using Helm, most likely you deployed a single instance of MongoDB running in a single container. For this section, you'll redeploy the chart with "replicaSet" enabled.

The authors of the MongoDB chart created it so that it supports deploying a MongoDB replica set through the use of Kubernetes StatefulSet for the secondary replica set. A replica set in MongoDB provides redundancy and high availability and in some cases, increased read capacity as clients can send read operations to different servers.

### Tasks

#### Upgrade the MongoDB Helm release to use replication

{% collapsible %}

```sh
helm upgrade orders-mongo stable/mongodb --set replicaSet.enabled=true,mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge
```

Verify how many secondaries are running

```sh
kubectl get pods -l app=mongodb
```

You should get a result similar to the below

```sh
NAME                               READY   STATUS    RESTARTS   AGE
orders-mongo-mongodb-arbiter-0     1/1     Running   1          3m
orders-mongo-mongodb-primary-0     1/1     Running   0          2m
orders-mongo-mongodb-secondary-0   1/1     Running   0          3m
```

Now scale the secondaries using the command below.

```sh
kubectl scale statefulset orders-mongo-mongodb-secondary --replicas=3
```

You should now end up with 3 MongoDB secondary replicas similar to the below

```sh
NAME                               READY   STATUS              RESTARTS   AGE
orders-mongo-mongodb-arbiter-0     1/1     Running             3          8m
orders-mongo-mongodb-primary-0     1/1     Running             0          7m
orders-mongo-mongodb-secondary-0   1/1     Running             0          8m
orders-mongo-mongodb-secondary-1   0/1     Running             0          58s
orders-mongo-mongodb-secondary-2   0/1     Running             0          58s
```

{% endcollapsible %}

> **Resources**
> - [https://docs.mongodb.com/manual/replication/](https://docs.mongodb.com/manual/replication/)
> - [https://github.com/helm/charts/tree/master/stable/mongodb#replication](https://github.com/helm/charts/tree/master/stable/mongodb#replication)