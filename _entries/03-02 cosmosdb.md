---
sectionclass: h2
sectionid: cosmos
parent-id: enhancing
title: Swap out MongoDB for CosmosDB

---

Your organisation has decided it wants to reduce the management overhead, needs to introduce 
global replication and improve the availability of MongoDB. To do this you will take advantage 
of CosmosDB.

CosmosDB has a MongoAPI driver so that you do not need to change any application code to 
port a MongoDB application to CosmosDB.

![](media/bde613c3c8baba4692deae7155513cd9.png)

1.  Deploy CosmosDB

2.  Import data from your application

3.  Configure application to connect to CosmosDB

Prebuilt containers to replace the captureorder and fulfillorder are available
but you need to replace MongoDB with CosmosDB with zero downtime. **Note, for this exercise
you will be deploying tag v4 of the containers.**

Resources:

<https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-introduction>