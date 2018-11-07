---
sectionclass: h2
sectionid: cosmos
parent-id: upandrunning
title: Swap out MongoDB for CosmosDB

---

Your organisation has decided it wants to reduce the management overhead, needs to introduce global replication and improve the availability of MongoDB. To do this you will take advantage of CosmosDB.

CosmosDB has a MongoAPI driver so that you do not need to change any application code to port a MongoDB application to CosmosDB.

> **Hint** Pay attention to how you can tune the throughout of CosmosDB.

![Application components](media/bde613c3c8baba4692deae7155513cd9.png)

1. Deploy CosmosDB
1. Configure application to connect to CosmosDB

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-introduction?wt.mc_id=CSE_(433127)>
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/connect-mongodb-account>
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/request-units>