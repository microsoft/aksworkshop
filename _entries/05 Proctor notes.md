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
    --resource-group akschallenge \
    --resource-type "Microsoft.Insights/components" \
    --name akschallengeproctor \
    --location eastus \
    --properties '{"Application_Type":"web"}'  
```

> **Note** Provide the **Instrumentation Key** to the attendees that they can use to fill in the `CHALLENGEAPPINSIGHTS_KEY` environment variables. If you're using the default built in Application Insights, just instruct attendees to delete the environment variable from their deployments.

## Availability scoring

On the Azure Portal, navigate to the Application Insights resource you created, click on **Availability** then click on **Add test**.

![Click on Availability](media/availability-scoring-1.png)

Then create a URL ping test to each team's public order capture API swagger endpoint `http://<public ip of order capture api>/swagger`

![Create a test](media/availability-scoring-2.png)

## Throughtput scoring

On the Azure Portal, navigate to the Application Insights resource you created, click on **Analytics**

![Click on Analytics](media/challenge-tracking-analytics.png)

Then you can periodically run the query below, to view how many orders each team has processed, especially after you load test one of the teams.

```
customEvents
| where name == "CaptureOrder to MongoDB"
| where customDimensions["team"] != "team-azch"
| where customDimensions["team"] != ""
| summarize count() by tostring(customDimensions["team"])
| render barchart
```

![Bar chart of orders processed](media/challenge-tracking.png)