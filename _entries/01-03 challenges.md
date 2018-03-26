---
sectionid: 4
sectionclass: h2
title: Challenges
parent-id: intro
---

The challenges are intended to be a challenge! Useful resources are provided to help you work through each challenge but step by step instructions are not provided. To ensure you progress at a good pace ensure workload is divided between team members where possible. This may mean anticipating work that might be required in a later challenge.

Each team is made of a Microsoft representative, a Microsoft partner representative and cutsomer(s) members. The Microsoft/Microsoft Partners representatives were not, initially, exposed to the challenges but they come with Advanced knowledge of Azure services. 

The challenge consists of two major iterations plus extra advanced sections. 
You are expected to conclude both the simple and advanced iterations, and perform as much advanced optional sections to get the highest score.
The first iteration, is focused on speed and simplicity. We will leverage Azure to get up and running with Kubernetes with minimal effort. 
The objective is to create an end to end minimal viable product. More specifically, we will focus on: 
- Deploying kubernetes cluster as a managed service (AKS), for quick Dev and Test
- Deploying the different micro-services of our application, using public docker images and helm charts
- Migrate some IaaS components to Azure managed services, to reduce the operational overhead 

The second iteration will put more attention on the operational requirements. One of the most important aspects of our final architecture is Security. 
Despite the easiness and convenience of AKS, the service is still in preview and lacks some key functionalities, which should be available at GA. 
Luckily, we can leverage another Azure container service (ACS engine). An open source tool, that allows the deployment of a custom Kubernetes cluster on Azure infrastructure. 
ACS is a test bed incubator for AKS, and its capabilities should be integrated to AKS over time.    
During this phase, we will focus on:
- Security at the different layers (Infrstructure, Application)
- Advanced monitoring and alerting     
- Business continuity 

At the end of the second day, each team will be given 15mn to present its work. Topcis you might cover during your presentation include:
- Solution architecture 
- Key learnings, mistakes, challenges
- Innovation, what makes your solution unique?  
- What could you do in day 3?  
 
The first 3 challenges, under section 2, involve getting Kubernetes and the application provisioned and **must be carried out sequentially**. After this there is flexibility as to how you proceed.

A Microsoft/Microsoft Partner team member will arrange for you to be added to theazurechallenge Azure Active Directory. When logging into Azure from the Azure CLI we recommend using ```az login --tenant YOUR-SUBSCRIPTION``` where your subscription is your corporate one, to ensure you are connected to the appropriate subscription.

If you feel you need assistance at any time, please ask a proctor.
