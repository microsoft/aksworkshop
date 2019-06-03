---
sectionid: codefresh
sectionclass: h2
parent-id: devops
title: Security scanning with Codefresh
---

As your application is growing and new libraries are being added, it is important to know about any security vulnerabilities before reaching production.

In this section you will add to our Codefresh pipeline and use the Aqua Security platform you configured in the previous section for security scanning.

Make sure that you have the following at hand:

* Your Aqua account username
* Your Aqua account password
* The URL of your Aqua server installation
* The username of an account user with the *Scanner* role
* The password of the account user with the *Scanner* role

### Tasks

#### Using the Aqua Codefresh plugin

To scan images as part of your CI/CD pipeline we've created a simple to use step, the [Codefresh-Aqua plugin](https://hub.docker.com/r/codefresh/cfstep-aqua/tags).

Navigate to the Codefresh pipeline you created earlier.  

Expand the *Environment variables* and add the following variables (you can also delete the `PORT` one as it is not needed):

* `AQUA_HOST` - the Aqua server from the previous section including port (`http://example.com:80`)
* `AQUA_USERNAME` - Your Aqua Username
* `AQUA_PASSWORD` - Your Aqua password


In the *Workflow* section make sure that the first option is selected - *Inline YAML* and add this step between the build and push steps.

```yaml
{% raw %}
  AquaSecurityScan:
    title: 'Aqua Private scan'
    image: codefresh/cfstep-aqua
    stage: test
    environment:
      - 'AQUA_HOST=${{AQUA_HOST}}'
      - 'AQUA_PASSWORD=${{AQUA_PASSWORD}}'
      - 'AQUA_USERNAME=${{AQUA_USERNAME}}'
      - IMAGE=${{build}}
      - TAG=latest

{% endraw %}            
```

Save and run the pipeline to get your security results.

#### Uh-oh! We found a vulnerability, let's fix it!

This concludes the scanning tasks. You have successfully used the Codefresh CI/CD platform to scan Docker images with the Aqua Security solution. Browse through the platforms to see what the issue is. 

To resolve it we'll need to update the version of OpenSSL. Open up the `Dockerfile` in your repo and comment out the following lines:

```docker
RUN echo 'http://dl-cdn.alpinelinux.org/alpine/v3.1/main' >> /etc/apk/repositories
RUN apk add "openssh==6.7_p1-r6"
```


> **Resources**
> * [Codefresh pipelines](https://codefresh.io/docs/docs/configure-ci-cd-pipeline/pipelines/)
> * [Codefresh YAML](https://codefresh.io/docs/docs/codefresh-yaml/what-is-the-codefresh-yaml/)
> * [Composition step](https://codefresh.io/docs/docs/codefresh-yaml/steps/composition-1/)
> * [Codefresh Registry](https://codefresh.io/docs/docs/docker-registries/codefresh-registry/)