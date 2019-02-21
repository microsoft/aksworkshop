---
sectionid: codefresh
sectionclass: h2
parent-id: devops
title: Security scanning with Codefresh
---

As your application is growing and new libraries are being added, it is important to know of any security vulnerabilities before reaching production.

You will create a Codefresh pipeline that will use the Aqua Security platform you setup in the previous section for security scanning.

[Codefresh](https://codefresh.io/features/) is CI/CD solution for containers and Kubernetes/Helm. We will use the CI part in this section. Codefresh offers free accounts in the cloud, which are fully functional and can be connected with any git repository and any Kubernetes cluster.

Make sure that you have the following at hand:
* Your Aqua account username
* Your Aqua account password
* The URL of your Aqua server installation
* The username of an account user with the *Scanner* role
* The password of the account user with the *Scanner* role

> **Hint**
> - The Aqua scanner requires direct communication with the Docker daemon, and this is why in Codefresh, we manually mount the docker socket.
> - The Aqua scanner image is not public, and this is why we need to connect the Aqua registry to Codefresh 

### Tasks

#### Create a Codefresh account

{% collapsible %}

You can create a free Codefresh account (free forever and fully functional) by signing up at [https://g.codefresh.io/signup](https://g.codefresh.io/signup). You can use any of the supported providers
shown such as Azure or Github.

You will be asked to confirm the permissions requests for your GIT provider. Codefresh does not commit
anything in your GIT repositories (it only reads them to check out code) and the privileges needed are mostly
for automatic triggers (i.e. starting a pipeline when a commit happens).

You will also be asked to provide a username for your Codefresh account. Once that is done you will see the main Codefresh User Interface

IMAGE HERE


> **Hint**
> Codefresh supports multi-login accounts. You can signup/login with multiple git providers
> and if the email used is the same, you will always reach the same Codefresh account.

For more information see the [create account documentation](https://codefresh.io/docs/docs/getting-started/create-a-codefresh-account/).

{% endcollapsible %}

#### Integrate the Aqua Registry into Codefresh

In order for Codefresh to be able to scan images for vulnerabilities, it needs access to the Aqua Vulnerability scanner. The scanner is offered as a Docker image itself, deployed on the private Aqua Registry (which is not public like Dockerhub).

{% collapsible %}

In the Codefresh UI, select *Account Settings* on the left sidebar and then click on *Configure* next to [Docker Registry](https://g.codefresh.io/account-admin/account-conf/integration/registry).

Click the *Add Registry* dropdown and then select *Other Registries*

Fill in the details for the Aqua registry with the following information:

* Registry name: `aquaregistry` (user defined)
* Username: Your Aqua username
* Password: Your Aqua password
* Domain: `registry.aquasec.com`

IMAGE HERE

Click the *Test* button to make sure that your credentials are correct and finally the *Save* button to apply your changes.
Codefresh is now connected to your Aqua Docker registry and can pull images from it.

For more information see the documentation on [external registries](https://codefresh.io/docs/docs/docker-registries/external-docker-registries/) and [custom registries](https://codefresh.io/docs/docs/docker-registries/external-docker-registries/other-registries/).

{% endcollapsible %}

#### Scan a public Docker image

You will first use Codefresh to scan a public docker image that already exists in Dockerhub.

{% collapsible %}



{% endcollapsible %}

#### Connect the Codefresh Registry to Aqua

#### Scan a private Docker image




> **Resources**
> * [Codefresh pipelines](https://codefresh.io/docs/docs/configure-ci-cd-pipeline/pipelines/)
> * [Codefresh YAML](https://codefresh.io/docs/docs/codefresh-yaml/what-is-the-codefresh-yaml/)
> * [Composition step](https://codefresh.io/docs/docs/codefresh-yaml/steps/composition-1/)
> * [Codefresh Registry](https://codefresh.io/docs/docs/docker-registries/codefresh-registry/)