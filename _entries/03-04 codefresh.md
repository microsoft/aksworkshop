---
sectionid: codefresh
sectionclass: h2
parent-id: devops
title: Security scanning with Codefresh
---

As your application is growing and new libraries are being added, it is important to know about any security vulnerabilities before reaching production.

In this section you will create a Codefresh pipeline that will use the Aqua Security platform you configured in the previous section for security scanning.

[Codefresh](https://codefresh.io/features/) is a CI/CD solution for containers and Kubernetes/Helm. You will use the CI part in this section. Codefresh offers free accounts in the cloud, which are fully functional and can be connected with any Git repository and any Kubernetes cluster.

Make sure that you have the following at hand:

* Your Aqua account username
* Your Aqua account password
* The URL of your Aqua server installation
* The username of an account user with the *Scanner* role
* The password of the account user with the *Scanner* role

> **Hint**
> - The Aqua scanner requires direct communication with the Docker daemon, and this is why in Codefresh, we manually mount the Docker socket.
> - The Aqua scanner image is not public, and this is why we need to connect the Aqua registry to Codefresh 

### Tasks

#### Create a Codefresh account

{% collapsible %}

You can create a free Codefresh account (free forever and fully functional) by signing up at [https://g.codefresh.io/signup](https://g.codefresh.io/signup). You can use any of the supported providers
shown such as Azure or Github.

![Codefresh signup](media/codefresh/codefresh-signup.png)

You will be asked to confirm the permissions requests for your GIT provider. Codefresh does not commit
anything in your GIT repositories (it only reads them to check out code) and the privileges needed are mostly
for automatic triggers (i.e. starting a pipeline when a commit happens).

You will also be asked to provide a username for your Codefresh account. Once that is done you will see the main Codefresh User Interface

![Codefresh User Interface](media/codefresh/codefresh-ui.png)


> **Hint**
> Codefresh supports multi-login accounts. You can signup/login with multiple git providers
> and if the email used is the same, you will always reach the same Codefresh account.

For more information see the [create account documentation](https://codefresh.io/docs/docs/getting-started/create-a-codefresh-account/).

{% endcollapsible %}

#### Integrate the Aqua Registry into Codefresh

In order for Codefresh to be able to scan images for vulnerabilities, it needs access to the Aqua vulnerability scanner. The scanner is offered as a Docker image itself, deployed on the private Aqua Registry (which is not public like Dockerhub).

{% collapsible %}

In the Codefresh UI, select *Account Settings* on the left sidebar and then click on *Configure* next to [Docker Registry](https://g.codefresh.io/account-admin/account-conf/integration/registry).

![Codefresh Integrations](media/codefresh/integrations.png)

Click the *Add Registry* dropdown and then select *Other Registries*.

Fill in the details for the Aqua registry with the following information:

* Registry name: `aquaregistry` (user defined - lowercase)
* Username: Your Aqua username
* Password: Your Aqua password
* Domain: `registry.aquasec.com`

![Integrating Aqua Registry](media/codefresh/connect-aqua-registry.png)

Click the *Test* button to make sure that your credentials are correct and finally the *Save* button to apply your changes.
Codefresh is now connected to your Aqua Docker registry and can pull images from it.

For more information see the documentation on [external registries](https://codefresh.io/docs/docs/docker-registries/external-docker-registries/) and [custom registries](https://codefresh.io/docs/docs/docker-registries/external-docker-registries/other-registries/).

{% endcollapsible %}

#### Scan a public Docker image

You will first use Codefresh to scan a public Docker image that already exists in Dockerhub.

{% collapsible %}

From the left sidebar in Codefresh click on *Pipelines*. The click the *Add pipeline* button on the top right.
Name the pipeline *aqua-scan-public-image* or something similar. 

Expand the *Environment variables* and add the following variables (you can also delete the `PORT` one as it is not needed).

* `AQUA_URL` - the Aqua server from the previous section including port (http://example.com:80)
* `AQUA_SCANNER_USER` - an Aqua user with scanner role
* `AQUA_SCANNER_PASSWORD` - the password of the Aqua user with scanner role. (click the encrypt checkbox)

![Aqua Variables](media/codefresh/aqua-variables.png)

In the *Workflow* section make sure that the first option is selected - *Inline YAML* and paste the following  [codefresh.yml](yaml-solutions/devops/codefresh/codefresh-public-scan.yml) into the editor (removing its previous contents):

```yaml
{% raw %}
version: '1.0'
steps:
  AquaScanPublicImage:
      title: Aqua Public scan
      type: composition
      composition:
        version: '2'
        services:
          targetimage:
            image: azch/frontend:latest
            command: sh -c "exit 0"
      composition_candidates:
        scan_service:
          image: registry.aquasec.com/scanner:3.5
          command: scan -H ${{AQUA_URL}} -U ${{AQUA_SCANNER_USER}} -P ${{AQUA_SCANNER_PASSWORD}} --local azch/frontend:latest
          environment:
          - AQUA_URL=${{AQUA_URL}}
          - AQUA_SCANNER_USER=${{AQUA_SCANNER_USER}}
          - AQUA_SCANNER_PASSWORD=${{AQUA_SCANNER_PASSWORD}}
          depends_on:
            - targetimage
          volumes: # Volumes required to run DIND
            - /var/run/docker.sock:/var/run/docker.sock
            - /var/lib/docker:/var/lib/docker
{% endraw %}            
```

In the example above we are scanning the [FrontEnd image](https://hub.docker.com/r/azch/frontend/tags). Feel free to replace the image with any other public one such as:

* `alpine:latest`
* `postgres:latest`
* `mongo:latest`
* `codefresh/cli:latest`
* `azch/captureorder:latest`



Click the *Save* button to apply your changes and then click the *Build* button to start the scan.

![Codefresh pipelines](media/codefresh/pipeline.png)

Wait for the scan to finish. You can click on the pipeline step to see the log. Once done,
go back to your Aqua Server instance, click on *Images*, then on *CI/CD* and take a look at the scan results.

![Security result](media/codefresh/public-security-scan.png)

For more information see the documentation on available [Codefresh steps](https://codefresh.io/docs/docs/codefresh-yaml/steps/). 

You have now successfully used Codefresh to scan a Docker image on the Aqua security platform.




{% endcollapsible %}

#### Connect the Codefresh Registry to the Aqua platform

In the previous task, you have scanned a public Docker image. In order to scan a private one, the Aqua scanner service must have access to the private Docker registry that hosts the image.

You can connect any supported private registry in Aqua, but since Codefresh already includes a private Docker registry with each account, you will set up access for the Codefresh registry.

{% collapsible %}

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
* *Registry URL* - `http://r.cfcr.io`
* *Username* - your Codefresh username
* *Password* - the Codefresh registry token you created before

![Adding Codefresh registry to Aqua](media/codefresh/adding-codefresh-registry-to-aqua.png)

Then click the *Save* button. 
The Aqua scanner is now able to access your Codefresh private registry.

{% endcollapsible %}

#### Scan a private Docker image

To scan a private Docker image, you will create a full Codefresh pipeline where:

1. Code gets checked out from a public repository
1. A Docker image is created
1. The Docker image is pushed into the Codefresh private Docker registry
1. The Aqua scanner is triggered
1. The Aqua scanner fetches the image from the Codefresh registry and scans it for vulnerabilities.

For this tutorial, you will scan the sample application at [https://github.com/codefresh-contrib/python-flask-sample-app](https://github.com/codefresh-contrib/python-flask-sample-app)

{% collapsible %}

From the left sidebar in Codefresh click on *Pipelines*. Then click the *Add pipeline* button on the top right.
Name the pipeline *aqua-scan-private-image* or something similar. 

Expand the *Environment variables* and add the following variables (you can also delete the `PORT` one as it is not needed):

* `AQUA_URL` - the Aqua server from the previous section including port (`http://example.com:80`)
* `AQUA_SCANNER_USER` - an Aqua user with scanner role
* `AQUA_SCANNER_PASSWORD` - the password of the Aqua user with scanner role.

![Aqua Variables](media/codefresh/aqua-variables.png)

In the *Workflow* section make sure that the first option is selected - *Inline YAML* and paste the following [codefresh.yml](yaml-solutions/devops/codefresh/codefresh-private-scan.yml) into the editor (removing its previous contents):

```yaml
{% raw %}
version: '1.0'
stages:
- checkout
- build
- scan
steps:
  main_clone:
    image: alpine/git:latest
    stage: checkout
    commands:
      - rm -rf python-flask-sample-app
      - git clone https://github.com/codefresh-contrib/python-flask-sample-app.git
  BuildDockerImage:
    title: Building Docker Image
    type: build
    stage: build
    image_name: my-private-image
    tag: latest
    working_directory: ${{main_clone}}/python-flask-sample-app
    dockerfile: Dockerfile    
  AquaScanPrivateImage:
      title: Aqua Private scan
      type: composition
      stage: scan
      composition:
        version: '2'
        services:
          targetimage:
            image: my-private-image:latest
            command: sh -c "exit 0"
      composition_candidates:
        scan_service:
          image: registry.aquasec.com/scanner:3.5
          command: scan -H ${{AQUA_URL}} -U ${{AQUA_SCANNER_USER}} -P ${{AQUA_SCANNER_PASSWORD}} --registry "Codefresh" ${{CF_ACCOUNT}}/my-private-image:latest
          depends_on:
            - targetimage
          volumes: # Volumes required to run DIND
            - /var/run/docker.sock:/var/run/docker.sock
            - /var/lib/docker:/var/lib/docker
      on_success: # Execute only once the step succeeded
        metadata: # Declare the metadata attribute
          set: # Specify the set operation
            - ${{BuildDockerImage.imageId}}: 
              - SECURITY_SCAN: true          
{% endraw %}            
```


In the example above we are building a Dockerfile and then scanning it with Aqua. We are also
using the custom [Codefresh meta-data](https://codefresh.io/docs/docs/docker-registries/metadata-annotations/) to mark the image with a boolean variable that shows it is scanned.


Click the *Save* button to apply your changes and then the *Build* button to start the scan.

![Codefresh private scan pipeline](media/codefresh/pipeline-private-scan.png)

Wait for the scan to be finished. You can click on the pipeline step to see the log. Once done,
go back to your Aqua Server instance, click on *Images*, then on *CI/CD* and take a look at the scan results.

![Private scan results](media/codefresh/private-security-scan.png)

You can also see the Docker image in the Codefresh registry if you click on *Images* in the Codefresh UI.

![Private Docker registry](media/codefresh/codefresh-registry.png)

Clicking on the image will also show you that it is marked as scanned.

![Image metadata](media/codefresh/image-metadata.png)

#### Using the Aqua Codefresh plugin

An alternative way to scan images, it to instruct the Aqua server itself to scan the image (instead of scanning in the Codefresh pipeline) using the [Codefresh-Aqua plugin](https://hub.docker.com/r/codefresh/cfstep-aqua/tags).

From the left sidebar in Codefresh click on *Pipelines*. Then click the *Add pipeline* button on the top right.
Name the pipeline *aqua-scan-private-image-plugin* or something similar. 

Expand the *Environment variables* and add the following variables (you can also delete the `PORT` one as it is not needed):

* `AQUA_HOST` - the Aqua server from the previous section including port (`http://example.com:80`)
* `AQUA_USERNAME` - Your Aqua Username
* `AQUA_PASSWORD` - Your Aqua password


In the *Workflow* section make sure that the first option is selected - *Inline YAML* and paste the following [codefresh.yml](yaml-solutions/devops/codefresh/codefresh-private-scan-plugin.yml) into the editor (removing its previous contents):

```yaml
{% raw %}
version: '1.0'
stages:
  - checkout
  - build
  - scan
steps:
  main_clone:
    image: 'alpine/git:latest'
    stage: checkout
    commands:
      - 'rm -rf python-flask-sample-app'
      - 'git clone https://github.com/codefresh-contrib/python-flask-sample-app.git'
  BuildingDockerImage:
    title: 'Building Docker Image'
    type: build
    stage: build
    image_name: codefresh/my-private-image
    tag: latest
    working_directory: '${{main_clone}}/python-flask-sample-app'
    dockerfile: Dockerfile
  AquaSecurityScan:
    title: 'Aqua Private scan'
    image: codefresh/cfstep-aqua
    stage: scan
    environment:
      - 'AQUA_HOST=${{AQUA_HOST}}'
      - 'AQUA_PASSWORD=${{AQUA_PASSWORD}}'
      - 'AQUA_USERNAME=${{AQUA_USERNAME}}'
      - IMAGE=codefresh/my-private-image
      - TAG=latest
    on_success:
      metadata:
        set:
          -
            '${{BuildingDockerImage.imageId}}':
              -
                SECURITY_SCAN: true
    on_fail:
      metadata:
        set:
          -
            '${{BuildingDockerImage.imageId}}':
              -
                SECURITY_SCAN: false

{% endraw %}            
```

Save and run the pipeline to get your security results.



This concludes the scanning tasks. You have successfully used the Codefresh CI/CD platform to scan Docker images with the Aqua Security solution.

{% endcollapsible %}




> **Resources**
> * [Codefresh pipelines](https://codefresh.io/docs/docs/configure-ci-cd-pipeline/pipelines/)
> * [Codefresh YAML](https://codefresh.io/docs/docs/codefresh-yaml/what-is-the-codefresh-yaml/)
> * [Composition step](https://codefresh.io/docs/docs/codefresh-yaml/steps/composition-1/)
> * [Codefresh Registry](https://codefresh.io/docs/docs/docker-registries/codefresh-registry/)