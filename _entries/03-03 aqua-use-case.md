---
sectionid: aqua-usage
sectionclass: h2
parent-id: devops
title: Using Aqua Security Platform
---

We will now run through the following use cases with Aqua.

> **Image Assurance**
> * Manually add image
> * Connect to your ACR
> * Scan an Image from your ACR
> * Create and edit Image Assurance Policy


> **Runtime Protection**
> * Block Unregistered Images
> * Block certain executable from running
> * Prevent Drift from happening



### Image Assurance

Image Assurance is a subsystem of Aqua CSP.  It is responsible for the following:

> * Scanning your images for known security issues (vulnerabilities, sensitive data, and malware).
> * Evaluating the scanning findings, according to Image Assurance Policies that you define and configure
> * Determining whether images are compliant, based on these policies and other system settings
> * Taking security-related actions that you define, such as preventing risky images from being deployed in a container, or reporting the image as "failed" to your CI/CD development system.
> * Providing complete reporting on all security risks found. You can review the results of the security evaluation either in the Aqua Server or in a SIEM or other system.


#### What is scanned?

Aqua scans images for CVEs (Common Vulnerabilities and Exposures) listed on the NVD web site, a U.S. government repository of standards-based vulnerability management data.

These image components are scanned:

> * OS Packages: Aqua checks the published security advisories issued by Operating System vendors for the various packages and versions related to their operating systems that are included in the image. These advisories list known vulnerabilities.
> * Programming Packages: Aqua checks the lists of known vulnerabilities for packages for several programming languages, according to version. It also checks whether there are replacement versions for packages with issues that fail Image Assurance Policies.
> * Configuration files: Aqua checks the image for sensitive data files such as keys or passwords, based on the patterns. 


#### Manually add an image to scan

We will now add an image from the public docker hub registry. 
> * Step 1) Click on `Images` on the left navigation section
> * Step 2) Click on the `+ ADD IMAGES` icon on the upper right side of the screen
> * Step 3) Make sure the registry is set to Docker Hub, and then type in centos and click `Search`
> * Step 4) Select the first repository line item, `centos`
> * Step 5) Then select the `latest` tag version and click `Add`


This is what it should look like:

![Aqua Output](media/aqua/aqua-add-centos.png)

This will start the scan of the latest centos image from Docker Hub.   It will not take long to scan the image.  Once finished scanning, feel free to view the results, and see how many vulnerabilities were detected by Aqua.  

> **Notice**
> how the image is marked as Approved, even though it has many high vulnerabilities. 

![Aqua Output](media/aqua/aqua-result-centos.png)


#### Connect to your ACR

Now we will integrate with your ACR so you can pull in other images that might be on there.
> * Step 1) Click on `System` on the left Navigation
> * Step 2) Select `Integrations`
> * Step 3) Click on the `Add Registry` button
> * Step 4) Give the Registry a name:  `ACR` for example.
> * Step 5) Under `Registry Type` select `Azure Container Registry`
> * Step 6) Fill in the `URL` , `Username`, and `Password` for your ACR
> * Step 7) Click on `Test connection`, and if successful , then click on `Save Changes` .

We now have integrated with your ACR , and you will have another option to pull your images from.
Like we did for manually adding images from Docker Hub, we can add an image from your ACR.
> * Step 1) Click on `Images` on the left navigation section
> * Step 2) Click on the `+ ADD IMAGES` button on the upper right side of the screen
> * Step 3) Make sure the registry is set to `ACR`, and then type in a name of an image and click `Search`
> * Step 4) Select the repository.
> * Step 5) Then select a tag and click on `Add`

This will start a scan of that image from your ACR.  Once finished scanning, you can view the results and see what the security posture of that image is. 

#### Connect the Codefresh registry

In order to scan images built in Codefresh and not yet pushed to ACR, we need to give  a pull secret to Aqua.


You can connect any supported private registry in Aqua, but since Codefresh already includes a private Docker registry with each account, you will set up access for the Codefresh registry.


First, you will create a Codefresh Registry Access Token. From the left sidebar click on *User Settings*.
Scroll down until you see the Codefresh Registry section.

![Codefresh registry](media/codefresh/registry-tokens.png)

Click on the *Generate* button to create a new access token. Give it any arbitrary name (e.g. `aqua-access`)
and click *Create* to get the token. Copy it into your clipboard by clicking the *Copy Docker login command to clipboard*.

![Registry token](media/codefresh/create-registry-token.png)

Paste the clipboard contents into an empty text file (you can use any text editor for this purpose). Finally 
click *OK* to close the dialog.

Now you are ready to give these credentials to Aqua.
Login into your Aqua account and expand *System* on the bottom of the left sidebar. Then click on *Integrations*. On the right-hand side click the *Add Registry* button. Click on the dropdown
*Docker v1/v1 Registry* and enter the following details:

* *Registry Name* - Codefresh (user defined)
* *Registry URL* - `https://r.cfcr.io`
* *Username* - your Codefresh username
* *Password* - the Codefresh registry token you created before

![Adding Codefresh registry to Aqua](media/codefresh/adding-codefresh-registry-to-aqua.png)

Then click the *Save* button. 
The Aqua scanner is now able to access your Codefresh private registry.

#### Create a Image Assurance Policy
Whenever Aqua scans an image, it checks the image against the Image Assurance policy.  Currently we don't have a Policy so everything scanned will be in the approved state, even if it contains vulnerabilities.

Let's create a Policy now. 

> * Step 1) Click on Policies
> * Step 2) Select Assurance Policy
> * Step 3) Select the Default Image Policy (the first one)
    
We can add any Available Image Assurance Control from the right side, by clicking on the `+` icon next to the control we want.

For this session, we will just add the `Vulnerability Severity` control .
Once added, select the severity level `High` , and then click `Save Changes` .

> This policy will mark any image as 'Non-compliant' if it contains at least one high severity vulnerability.

Click on the Images section now, and you open up the centos image we scanned.  Notice how it's marked as Non-compliant. Before it was marked as Approved. 

![Aqua Output](media/aqua/aqua-result-fail-centos.png)

#### Create a Runtime Policy

You can configure one or more Runtime Policies to restrict the runtime activities of containers, according to the security requirements of your organization. Restriction can mean either or both of the following:
> * Preventing the running of the container. For example, you can configure a Runtime Policy to block the running of a container based on an image that has been found to be non-compliant during Image Assurance.
> * Preventing the execution by the container of certain runtime activities. For example, a Runtime Policy could block running a blacklisted executable in a container, or prevent particular volumes from being mounted by a container.


Let's create the Runtime Policy now.

> * Step 1) Click on "Policies" on the left navigation
> * Step 2) Select "Runtime Policies"
> * Step 3) Select the "Default" Policy

The Default Policy contains a few controls already. We want to make sure that this Policy is set to `Enable` and enforcement mode is set to `Enforce` . 

If not already added, we should add the following controls:
> * Executable Blacklist - add `/bin/date`
> * Drift Prevention 
> * Block Unregistered Images
> * Block Non-compliant Images

![Aqua Output](media/aqua/aqua-runtime-policy.png)

Click on `Save changes` .

This policy will Block any unregistered images, any non-compliant images, block black listed executable and prevent drift. 

We have now created our Runtime Policy.  Next section will demostrate the controls we just added. 

#### Block Unregistered Images

From your Azure cloud shell, we are going to deploy an application.

Type the following command to deploy an nginx image.

```sh
kubectl create deployment nginx --image=nginx:latest
```

This will try to deploy the nginx application, but it will fail.  Due to our runtime policy, Aqua will block it.

Type in:
```sh
kubectl get pods
```

This will list all the pods running, but you will see an `RunContainerError` on the nginx pod.

To view the detail, we will need to describe the pod.   Run the following command to view the details:

```sh
kubectl describe pod NAMEOFPOD
```
The last line would show why Aqua is blocking it. 

> **Note** To delete the nginx pod name, you can run `kubectl delete deployment nginx` .


Let's register this nginx container with Aqua, so Aqua doesn't block it again. 

> * Step 1) Click on Images
> * Step 2) Click on "+ Add IMAGES" 
> * Step 3) Registry should be Docker Hub, search for and take the latest tag of nginx
> * Step 4) Click on "Add", and let Aqua scan and register the image.

Now that the nginx:latest image is register with Aqua, we can deploy it without having to worry that Aqua will be blocking it. 

```sh
kubectl create deployment nginx --image=nginx
kubectl get po
```
This will show that he nginx is in the running stage. 


#### Block certain executable from running

In our Default Runtime policy we had blocked `date` from running.  If we exec into the pod, we should not be able to execute the date command. 

Run the following command, but replace <PODNAME> with the name of the nginx pod.
```sh
kubectl exec -it <PODNAME> bash
```

This will put us in the nginx pod.   Try to run the date command.  You will get a `permission denied error` .  This is because we black listed this executable in our runtime policy.

#### Drift Protection

Aqua’s image drift prevention ensures that containers remain immutable and do not deviate from their originating image, further limiting the potential of abuse. 

To simulate a drift, we will copy an allowed executable, like `ls`, to another name like `sl`.

```sh 
    cp /bin/ls /bin/sl
```

When we try to run the sl command, Aqua will block it, as sl was not in the original image, so you will get a `Permission Denied` error.


There is a lot more that can be done with Aqua which we haven't touch upon due to the limited time.   Other controls are: Network Nano Segmentation, Secrets Management, and Compliance report.