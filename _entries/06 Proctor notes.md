---
sectionid: proctornotes
sectionclass: h1
title: Proctor notes
is-parent: yes
---

## Creating the Challenge Application Insights resource

You can quickly create the Application Insights resource required to track the challenge progress and plot the results by running the below code:

```sh
az resource create \
    --resource-group <resource-group> \
    --resource-type "Microsoft.Insights/components" \
    --name akschallengeproctor \
    --location eastus \
    --properties '{"Application_Type":"web"}'  
```

> **Note** Provide the **Instrumentation Key** to the attendees that they can use to fill in the `CHALLENGEAPPINSIGHTS_KEY` environment variables.

<!--
## Availability scoring

On the Azure Portal, navigate to the Application Insights resource you created, click on **Availability** then click on **Add test**.

![Click on Availability](media/availability-scoring-1.png)

Then create a URL ping test to each team's public order capture API swagger endpoint `http://<public ip of order capture api>/swagger`

![Create a test](media/availability-scoring-2.png)
-->

## Throughput scoring

On the Azure Portal, navigate to the Application Insights resource you created, click on **Analytics**

![Click on Analytics](media/challenge-tracking-analytics.png)

Then you can periodically run the query below, to view which team has the highest successful requests per second (RPS).

```
requests
| where success == "True"
| where customDimensions["team"] != "team-azch"
| summarize rps = count(id) by bin(timestamp, 1s), tostring(customDimensions["team"])
| summarize maxRPS = max(rps) by customDimensions_team
| order by maxRPS desc
| render barchart
```

![Bar chart of requests per second](media/rps.png)