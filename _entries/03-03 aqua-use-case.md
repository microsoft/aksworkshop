---
sectionid: aqua-usage
sectionclass: h2
parent-id: devops
title: Using the Aqua Cloud-native Security Platform
---

We will now run through the following use cases with Aqua:

> **Image Assurance**
> * Manually add an image to scan
> * Connect to your Azure container registry
> * Scan an image from your Azure container registry
> * Connect to your Codefresh registry
> * Update the default image assurance policy

> **Runtime Protection**
> * Update the default runtime policy to
> * Block unregistered images
> * Block certain executables from running
> * Prevent drift from happening

### Image Assurance

Image Assurance is a subsystem of Aqua CSP.  It is responsible for the following:

> * Scanning your images for security issues (including known vulnerabilities, sensitive data, malware, configuration issues and open source software).
> * Comparing scan results to applicable image assurance policies to determine compliance and actions to be taken accordingly (including generating audit events, failing CI/CD pipelines, and marking images as non-compliant).
> * Reporting all security risks found with detailed and actionable information in CI/CD tools, the Aqua web console, and other systems.

#### What is scanned?

Aqua scans images for known vulnerabilities, sensitive data, malware, configuration issues and open source software. Vulnerabilties and malware are identified by Aqua's CyberCenter which aggregates and correlates multiple feeds from the National Vulnerability Database, various vendor advisories, Whitesource for open source, and proprietary research.

Aqua's scanners send this information to the Aqua CyberCenter:

> * Aqua image digest
> * Image operating system
> * List of layer digests in the image
> * List of packages installed in the image, including:
>   * Package format (e.g., rpm, deb, apk)
>   * Package name (e.g., nginx)
>   * Package version
>   * Package hash (if applicable)
> * List of non-package executables, including:
>   * Name of software
>   * Version
>   * CPE
>   * SHA1 hashes of file contents, for purposes of malware identification
> * List of programming-related files (e.g., php, js, jar):
>   * SHA1 hashes of file contents

#### Manually add an image to scan

We will now add an image from the public Docker Hub registry:

> 1. In the Aqua web console, in the navigation menu on the left, click on **Images**.
> 1. In the upper right corner, click on the **Add Images** button.
> 1. In the Search Term field, enter: **jboss/wildfly**
> 1. Click the **Search** button.
> 1. Select the **jboss/wildfly** repository.
> 1. Check the **9.0.2.Final** tag.
> 1. Click the **Add** button.

This is what you should see as you perform the above steps:

![Aqua Output](media/aqua/aqua-add-jboss-wildfly.png)

This will start the scan of the the jboss/wildfy image from Docker Hub. It will not take long to scan the image.  Once finished scanning, feel free to view the results, and see how many vulnerabilities were detected by Aqua.

Aqua CyberCenter uses includes a vulnerability feed from WhiteSource, the market leader in open source software security. This is unique to Aqua in the cloud-native security marketplace, and allows us to find more vulnerabilities and report them more accurately.

To see vulnerabilities found by WhiteSource, on the Vulnerabilities tab of the jboss/wildfly:9.0.2.Final image scan results, you can search by **WS-**:

![Aqua Output](media/aqua/aqua-whitesource-vulnerabilities.png)

Aqua also uses WhiteSource to identify open source software licenses, and allows you to create image assurance policies that determine compliance based on allowed or disallowed licenses.

To see licenses used by resources as identified by WhiteSource, go to the Resources tab of the jboss/wildfly:9.0.2.Final image scan results:

![Aqua Output](media/aqua/aqua-whitesource-licenses.png)

> **Notice** how the image is marked as Approved, even though it has many high vulnerabilities. This will change later when we apply image assurance policies. 

![Aqua Output](media/aqua/aqua-result-jboss.png)

#### Connect to your Azure container registry

Now we will integrate with your Azure container registry so you can pull in other images that might be on there.

> 1. In the Aqua web console, in the navigation menu on the left, click **System**.
> 1. Click **Integrations**.
> 1. Click the **Add Registry** button.
> 1. In the Registry Name field, enter: **ACR**
> 1. In the Registry Type dropdown list, select: **Azure Container Registry**
> 1. In the Registry URL field, enter the registry domain created by you in this workshop (e.g. https://akschallengeXXXXXXXX.azurecr.io)
> 1. In the Username field, enter the Application/Client ID provided to your for this workshop.
> 1. In the Password field, enter the Application Secret Key provided to your for this workshop.
> 1. Click the **Test Connection** button.
> 1. Click the **Save** button.

#### Scan an image from your Azure container registry

We have now integrated with your Azure container registry, and you will be able to select it when adding images to Aqua. Let's do that now.

> 1. In the Aqua web console, in the navigation menu on the left, click **Images**.
> 1. In the upper right corner, click on the **Add Images** button.
> 1. In the Registry dropdown list, select: **ACR**
> 1. In the Search Term field, enter: **color-coded**
> 1. Click the **Search** button.
> 1. Select the **&lt;username&gt;\/color-coded** repository.
> 1. Check the **Add All** option.
> 1. Click the **Add** button.

This will start a scan of the images of the repository of your ACR registry.  When the scans are finished, you can review their results on the Images page.

#### Connect to your Codefresh registry

In order to scan images built in Codefresh and not yet pushed to ACR, we will generate an access token for Aqua.

To create the access token, in Codefresh, in the navigation menu on the left, click **User Settings**, and scroll down until you see the **Codefresh Registry** section, then click the **Generate** button:

![Codefresh registry](media/codefresh/registry-tokens.png)

In the Key Name field, enter **aqua-access**, click the **Create** button, click the **Copy token to clipboard** link, and click the **OK** button:

![Registry token](media/codefresh/create-registry-token.png)

Make sure you don't replace the token on your clipboard, or temporarily paste the value to a text editor, because you'll need it below.
00759a79c828322b6861856e9d59086a

Now, in Aqua, connect to your Codefresh registry:

> 1. In the Aqua web console, in the navigation menu on the left, click **System**.
> 1. Click **Integrations**.
> 1. Click the **Add Registry** button.
> 1. In the Registry Name field, enter: **Codefresh**
> 1. In the Registry URL field, enter: **https://r.cfcr.io**
> 1. In the Username field, enter your Codefresh username.
> 1. In the Password field, enter the access token you generated in Codefresh and copied to your clipboard.
> 1. Click the **Test Connection** button.
> 1. Click the **Save** button.

![Adding Codefresh registry to Aqua](media/codefresh/adding-codefresh-registry-to-aqua.png)

> **Note:** because the Codefresh registry API does not support search, the Image Search step of Test Connection will fail. This is OK, and you should save the registry connection anyway. Later, if you want to add images from this registry on the Images page, you'll need to select the registry, and enter the fully qualified image name into the search field (e.g. r.cfcr.io/burbanski/burbanski/color-coded:devsecops-91fc4da).

#### Update the default image assurance policy
After Aqua scans an image, it compares the results to all applicable image assurance policies. When a control in an applicable image assurance policy fails, several actions can be taken, including marking the image as non-compliant. Initially, Aqua includes a default image assurance policy that has no controls, so all image scans will pass image assurance, even if they have vulnerabilities.

Let's update the default image assurance policy now:

> 1. In the Aqua web console, in the navigation menu on the left, click **Policies**.
> 1. Click **Assurance Policies**.
> 1. Click the **Default** policy of type **Image**.
> 1. Under Controls, click **Vulnerability Severity**.
> 1. In the Vulnerability Severity control configuration, click **High**.
> 1. Note the actions that will be taken if any control of this policy fail, including marking failed images as non-compliant. This policy will mark any image that contains one or more high severity vulnerabilities as non-compliant.
> 1. Click the **Save** button.

Go back to the Images page, and open the scan results for the jboss/wildfly:9.0.2.Final image that we scanned earlier. Notice how this image is now marked as non-compliant by the Default image assurnace policy, showing which control failed and what actions are needed to make the image compliant:

![Aqua Output](media/aqua/aqua-result-fail-jboss.png)

### Runtime Protection

Runtime policies (and image profiles, vulnerability shields and container firewall services) can be used to monitor and enforce controls at runtime, according to your organization's security requirements.

Enforcement can prevent containers that use non-compliant and/or unregistered images from running at all; or enforcement can prevent specific things from happening inside of running containers (e.g. certain executables from running, certain volumes from being mounted, etc.).

#### Update the default runtime policy

Let's update the default container runtime policy now:

> 1. In the Aqua web console, in the navigation menu on the left, click **Policies**.
> 1. Click **Runtime Policies**.
> 1. Click the **Aqua default runtime policy** policy of type **Container**.
> 1. Under Enforcement Mode, click **Enforce**.
> 1. Notice that the default policy already contains some controls.
> 1. Under Controls, click **Executables Blacklist**.
> 1. In the Executables Blacklist control configuration, in the exectuable name field, enter **/bin/date**, and click the **Add** button.
> 1. Under Controls, click **Block Unregistered Images**.
> 1. Under Controls, click **Block Non-compliant Images**.
> 1. Click the **Save** button.

![Aqua Output](media/aqua/aqua-runtime-policy.png)

#### Block unregistered images

In your Azure cloud shell, we're going to try to deploy an application.

Run this command to deploy nginx:

```sh
kubectl create deploy nginx --image=nginx:latest
```

This will try to deploy the nginx application, but it will fail due to our runtime policy.

Run this command to check the status of the pod:

```sh
kubectl get pods
```

Notice that the nginx pod has a status of `RunContainerError`.

Run this command to get additional details on the pod status (using the full name of the nginx pod output by previous command):

```sh
kubectl describe pod <name>
```

You should see this message under Events:

```text
[Aqua Security] You do not have permission to execute this command. Unregistered image
```

Run this command to delete the nginx deployment:

```sh
kubectl delete deploy nginx
```

Now, let's register the nginx image, so Aqua will allow it to be deployed:

> 1. In the Aqua web console, in the navigation menu on the left, click on **Images**.
> 1. In the upper right corner, click on the **Add Images** button.
> 1. In the Registry dropdown list, select: **Docker Hub**
> 1. In the Search Term field, enter: **nginx**
> 1. Click the **Search** button.
> 1. Select the **nginx** repository.
> 1. Check the **latest** tag.
> 1. Click the **Add** button.

When the nginx:latest image is done scanning, when can try to deploy it again.

Run these commands:

```sh
kubectl create deploy nginx --image=nginx:latest
kubectl get po
```

The nginx pod should now be running. 

#### Block certain executables from running

Our default runtime policy blacklists the `date` executable. If we exec into the pod, we should not be able to execute the date command. 

Run this command to exec into the nginx container (using the full name of the nginx pod output by previous command):

```sh
kubectl exec -it <name> bash
```

Notice that we are now in the nginx container as the root user (something else that can be prevented by Aqua). As such, there's nothing we should not be able to do. However, if we try executing the `date` executable, we will get a `Permission denied` error message. This is because Aqua blocked that executable from running.

#### Prevent drift from happening

Our default runtime policy prevents drift. Drift prevention ensures that your containers remain immutable, and protects you from both malicious attacks and bad habits by not allowing executables to run that were not part of the original image and/or not allowing the container to run when image parameters have changed.

To simulate a drift, we will copy an allowed executable, like `ls`, to another name like `list`:

```sh 
    cp /bin/ls /bin/list
```

When we try to run the `list` command, instead of getting a list of the contents of the current directory, we will get a `Permission denied` error message. This is because Aqua considered that new executable to be drift and blocked that executable from running.

As you may have gathered when navigating Aqua during the workshop, Aqua has many more capabilities than were explored here, to include image profiles, vulnerability shields, container firewall services, secrets management, infrastructure discovery with pen testing and CIS benchmark testing, workload monitoring and more.