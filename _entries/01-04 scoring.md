---
sectionid: scoring
sectionclass: h2
title: Scoring
parent-id: intro
---

To add an element of competitiveness to the workshop your solutions will be evaluated using both remote monitoring and objective assessments. At the end of the workshop we will announce a winner. You will be scored under the following areas:

### Availability

Application uptime over period of the workshop. We will be continuously making HTTP requests to your API.

### Throughput

Ability to cope with periodic load tests, through the number of processed requests. These will be order submissions to `http://<your endpoint>:80/v1/order/`. We will be directing up to 2000 users to your application.

You can run Docker image below to send off a number of POST requests and get the results.

> **Note** You'll need to run this on your local machine. It will not work on Azure Cloud Shell.

```sh
export URL=http://<public ip of capture order service>/v1/order
export DURATION=1m
export CONCURRENT=300
docker run --rm -it azch/loadtest -z $DURATION -c $CONCURRENT -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -m POST $URL
```

> **Note** You may also use Azure DevOps to do load testing.

### Extra tasks

There will be a list of extra tasks, intermediate and advanced level. Each task, successfully accomplished, counts for extra bonus points.

### Team

You should have been provided a team name. If not, come up with a unique name and make sure to set it in the enviornment variables to be able to properly track your progress.