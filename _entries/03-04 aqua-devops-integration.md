---
sectionid: aqua-devops-integration
sectionclass: h2
parent-id: devops
title: Integrating Aqua Scanning with Azure DevOps
---

Many Aqua customers want to shift security left and empower developers to scan early and often, on their desktops and integrated with their CI/CD pipelines. They want developers to receive the information they need to identify, understand and fix vulnerabilities without relying on other teams and accessing other tools. This section shows how Aqua scanning can be integrated with Azure DevOps pipelines.

### Install the Aqua Container Security Extension

To install the Aqua Container Security extension in your Azure DevOps environment from the Visual Studio Marketplace, follow this link:

<https://marketplace.visualstudio.com/items?itemName=aquasec.aquasec>

Click on the **Get it free** button:

![Aqua Output](media/aqua/aqua-devops-1.png)

Select the Azure DevOps organization that was created for this lab, and click the **Install** button:

![Aqua Output](media/aqua/aqua-devops-2.png)

Proceed to your Azure DevOps organization by clicking the **Proceed to organization button** button:

![Aqua Output](media/aqua/aqua-devops-3.png)

### Configure the Aqua Scanner Connection

Select your **captureorder** project:

![Aqua Output](media/aqua/aqua-devops-4.png)

Go to **Project Settings -> Service connections**, and click the **New service connection** button:

![Aqua Output](media/aqua/aqua-devops-5.png)

Select **Generic**, and click the **Next** button:

![Aqua Output](media/aqua/aqua-devops-6.png)

Provide values for the Server URL, Username, Password/Token Key and Service connection name fields as follows, and click the **Save** button:

> **Note** Replace the URL shown in the screenshot below with the URL you're using to connect to Aqua in your lab environment.
> **Note** The example uses the Aqua administator user to connect the scanner to the server. It's a best practice to create a new Aqua user with scanner only permissions for these connections.

![Aqua Output](media/aqua/aqua-devops-7.png)

### Configure the Aqua Registry Connection

The Aqua Security Scanner extension can be used to scan both Windows and Linux images. The extension includes a scanner for Windows images, but a scanner for Linux images must be pulled from Aqua's private registry (or otherwise downloaded and added to the local Docker repostory of the Azure DevOps host where the image will be scanned) prior to scanning. For Azure DevOps hosted agents, this must be done each time. For customer managed agents, this can be done once.

We will now create a Docker Registry service connection for the Aqua private registry, so we can login to the Aqua registry prior to the Aqua scan in our pipeline.

Click the **New service connection** button:

![Aqua Output](media/aqua/aqua-devops-8.png)

Select **Docker Registry**, and click the **Next** button:

![Aqua Output](media/aqua/aqua-devops-9.png)

Provide values for the Registry Type, Docker Registry, Docker ID, Docker Password and Service connection name fields as follows, and click the **Save** button:

> **Note** The Docker ID and Docker Password as the same as previously provided in this lab when installing Aqua:
>
> * Username: `aqua.lab.2020.1@gmail.com`
> * Password: `P@ssword01`

![Aqua Output](media/aqua/aqua-devops-10.png)

### Add the Aqua Scan Task to Pipeline

Select your **azch-captureorder** pipeline:

![Aqua Output](media/aqua/aqua-devops-11.png)

Edit the pipeline by clicking the **Edit** button:

![Aqua Output](media/aqua/aqua-devops-12.png)

Select the **Docker@2** task:

![Aqua Output](media/aqua/aqua-devops-13.png)

And replace it with this YAML:

> **Note** This will make a number of changes to the pipeline including:
> 1. Separating the Docker build and push commands
> 1. Using a Bash task to build and tag the image to avoid problems with scanning images in the local repository with invalid names beginning with ***/, something that is peculiar to Azure DevOps hosted agents and the Docker task
> 1. Logging into the Aqua private registry using the registry service connection created earlier so that the Aqua scanner image can be pulled during the scan task
> 1. Adding the Aqua scan task (which can also be configured via a task UI provided by the extension)

> **Note: You may need to update the Aqua scanner version to match the version deployed (latest) for the workshop. For example, if this workshop takes place after the 5.0 release, replace the 4.6 tag with 5.0 like so: 'registry.aquasec.com/scanner:5.0'**

```yaml
    
    - task: Bash@3
      displayName: Build image
      inputs:
        targetType: 'inline'
        script: |
          # Write your commands here
          set -x
          docker build -t captureorder:$(tag) .
          docker tag captureorder:$(tag) $(acrEndpoint)/captureorder:$(tag)
          
    - task: Docker@2
      displayName: Login into Aqua registry
      inputs:
        containerRegistry: 'aquaRegistry'
        command: 'login'
        
    - task: aquasecScanner@4
      displayName: Scan image with Aqua
      inputs:
        image: captureorder:$(tag)
        scanType: 'local'
        register: false
        hideBase: false
        showNegligible: false
        windowsScannerVersion: '4.2.0'
        connection: 'aqua-console'
        scanner: 'registry.aquasec.com/scanner:4.6'
        customFlags: '--layer-vulnerabilities'
        
    - task: Docker@2
      displayName: Push image
      inputs:
        containerRegistry: $(dockerRegistryServiceConnection)
        repository: captureorder
        command: push
        tags: $(tag)
          
```

In the Tasks menu on the right, select the **Aqua Security** task to note the UI provided by the Aqua Security extension for configuring Aqua Security tasks:

![Aqua Output](media/aqua/aqua-devops-14.png)

Click the **Save** button to save your changes to the pipeline (which will trigger a run of the pipeline):

![Aqua Output](media/aqua/aqua-devops-15.png)

In the Save dialog, click the **Save** button again:

![Aqua Output](media/aqua/aqua-devops-16.png)

Go back to **Pipelines**, select **Runs**, and select the current run triggered by the pipeline change made above:

![Aqua Output](media/aqua/aqua-devops-17.png)

You can drill down on the current stage to see more details of the run:

![Aqua Output](media/aqua/aqua-devops-18.png)

Eventually, you should see the Aqua scan task fail, at which point you can return to the job summary:

![Aqua Output](media/aqua/aqua-devops-19.png)

You can view the Aqua scan results by selecting the **Aqua Scanner Report** tab, and then the different tabs of the report itself:

![Aqua Output](media/aqua/aqua-devops-20.png)

Often, the quickest path to remediating a vulnerability is to check if there's a known fix in a later version of the effected resource, reference the later version in your application, and build again:

![Aqua Output](media/aqua/aqua-devops-21.png)

This concludes the lab. Thank you for participating.