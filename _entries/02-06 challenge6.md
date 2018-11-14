---
sectionclass: h2
sectionid: cosmos
parent-id: upandrunning
title: Swap out MongoDB for CosmosDB

---

Your organisation has decided it wants to reduce the management overhead, needs to introduce global replication and improve the availability of MongoDB. To do this you will take advantage of CosmosDB.

CosmosDB has a Mongo API driver so that you do not need to change any application code to port a MongoDB application to CosmosDB.

> **Hint** Pay attention to the Cosmos DB metrics, especially around throttling, and scale up as needed.

![Application components](media/cosmosdb.png)

### Tasks

1. Deploy CosmosDB
1. Configure application to connect to CosmosDB
1. Verify that the orders are making into your CosmosDB collection

> **Resources**
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-introduction?wt.mc_id=CSE_(433127)>
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/connect-mongodb-account>
> * <https://docs.microsoft.com/en-us/azure/cosmos-db/request-units>