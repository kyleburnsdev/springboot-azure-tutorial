# Spring Boot on Azure Web Apps for the absolute beginner

## Overview

This repository will document the progressive journey of a .NET developer learning to create a useful application using Spring Boot and Java deployed on Azure.
I was recently asked to help a customer get started with their Spring Boot application on Azure and found that I needed to piece together bits and pieces from various online resources. Each of these resources had valuable pieces of information, but were either "not enough" or "too much" for my goals. I decided to create this tutorial in hopes that what is "just right" for me will also be for somebody else.

Luckily, the reader will be spared much of the trial and error process and go straight to the successful path.

## Goals

For the application that will be progressively built in this repository to be considered successful, a few things should be taken into account:

- The resulting application may be simple, but should be something that can evolve into a reasonable enterprise solution
- Application should be deployable to Azure App Service
- Keep as few moving parts as is practical
- Account for how the application will be monitored operationally
- Do not store secrets in source files

At any point I reach a point where more than one path forward is available, the above points will guide the decision.

## Pre-Reqs

### Java Runtime

### Maven

### Visual Studio Code (optional, but nice)

### Azure Subscription

## Getting started - The minimal app

If you're starting off by cloning this repo, much of the information in this section won't apply to you. Hopefully you are instead walking through the process yourself to learn

- Create project directory
- Create minimal pom.xml file

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.kyleburnsdev</groupId>
  <artifactId>java-simple-app</artifactId>
  <version>1.0-SNAPSHOT</version>
</project>
```

- Run `mvn package` at command line

At this point, if the pre-requisites are installed correctly and the project was set up correctly, you should see a message similar to `[WARNING] JAR will be empty - no content was marked for inclusion!` in the build output as well as `BUILD SUCCESS`.

> If you don't see success messages at this point, STOP AND DEBUG. We're going to move in small increments that are more easy to debug

## Getting started - Adding Spring Boot

Now that you've made sure that Maven is set up and doing its job, it is time to start making this a Spring Boot application. After the next set of modifications, you will have a basic Spring Boot web application that listens on port 8080 of your local machine. It won't serve any content yet, but you will be able to verify that Spring Boot loads and everything is ready for you to start adding functionality.

### Update pom.xml

### Add parent package

By setting the "parent" package for our project to the default Spring Boot starter parent, we automatically have a lot of the correct dependencies and versions pulled in for us. There are more advanced ways to make a Spring Boot application without setting this up, but for the purposes of the application we're building we will use the easy route. The `parent` XML element should be added as a child to `project`

```xml
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.0.6</version>
    <relativePath/>
  </parent>
```

### Add Spring Boot starter web dependency

Combined with setting the parent package, we need to declare a dependency on the Spring Boot starter web package. This is done by adding a `dependencies` section as a sibling to `parent`

```xml
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
  </dependencies>
```

### Configure `build` section

The final section that will be added to the pom at this point in the evolution of the application is the `build` section, which is also a sibling element to `parent` and `dependencies`. The things that need to be accomplished are:

- Ensure that the artifact being built is named `app.jar`. This will be important later when it is time to deploy the application to Azure, so we will go ahead and set it now
- Import the Spring Boot Maven plugin, which works in the packaging process to ensure that the `app.jar` is re-written into an self-executing jar file

```xml
  <build>
    <finalName>app</finalName>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
```

### Create Application.java

Our project still has no classes defined, so we are going to add a class that will serve as the entry point to the application. Application.java is created in the folder structure under the java src directory and a subfolder structure to match the namespacing of the class. Documentation on the SpringApplication annotation and classes decorated with it can be found in the official [Spring Documentation] (https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-spring-application.html). The full path to the file is `src/main/java/com/kyleburnsdev/Application.java`.

A couple of important things to note at this point:

- Spring Boot requires classes to declare namespaces for it auto-configuration to work
- Maven is driven heavily by convention, so using the expected folder structure will help keep you on the path to success and deciding that you like your own convention better is possible but will cause a lot of unnecessary pain in the process

### Test the changes

With these changes in place, you should be able to use Maven to create an updated package and execute that package from the command line

```bash
mvn clean package
mvn spring-boot:run
```

The output will include a Spring Boot banner and if it reports success you will be able to navigate to <http://localhost:8080> where you will see a page marked "Whitelabel Error Page"

## A word about health monitoring

Before we actually add the first controller, it's probably a good time to talk about how developers can think ahead and save themselves and others from future frustration. We almost have the minimum amount of code in place to demonstrate a successful response from a web service. With just a little bit of effort, we can create a situation where we are able to validate that the web server and our application code run in a way that can later have automation put around it to prove "is the web service itself up".

Regardless of the technology stack, I like to start my projects with a health monitoring endpoint. Health monitoring has been a requirement for applications that I have supported over my career and it is always much smoother to set up monitoring when the application development team has provided an endpoint specifically intended for that purpose. I will typically create two endpoints - 1 for the most basic operation of the service being able to respond to HTTP requests and one to validate that external dependencies of the application can be reached by the application. If we build the first of our monitoring endpoints as the first endpoint in the application, it provides us as developers with the advantage of being able to easily determine whether we have broken the core functionality of the framework. As we progressively add functionality, we can always go back to ensure that the health monitoring endpoint still works.

Luckily, since we are utilizing capabilities in the Spring Boot framework, much of the work has already been done for us and all we have to do is add a dependency on Spring Boot Actuator to the project POM

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

After adding this dependency, rebuild the application and navigate to the built-in health check endpoint created by Actuator, <http://localhost:8080/actuator/health>. I would recommend using curl to hit this endpoint to avoid it being handled as a file download by the browser.

>> NOTE: for now the health check doesn't do much interesting work except verify that the site is running. We'll add more interesting checks later.

## Adding the first controller

The next step in the evolution of the application is to enable it to do something other than serve up 404 responses. To accomplish this, add a new Java source file called `src/main/java/com/kyleburnsdev/HomeController.java`. At this point, the class is pretty simple:

```java
package com.kyleburnsdev;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(path="/")
public class HomeController {
    @GetMapping
    public @ResponseBody String greeting() {
        return "Hello from Spring Boot";
    }
}
```

Important things to note about the class include:

- The `@Controller` annotation on the class tells Spring that this is a Controller expected to respond to HTTP requests
- The  `@RequestMapping` annotation on the class provides the default URL prefix for all of the operations served by this controller
- The `@GetMapping` annotation on the `greeting` method tells Spring that the method should be executed when requests to `/` are made using the GET HTTP verb
- The `@ResponseBody` annotation on the return type of `greeting` tells Spring to map the string returned by the method into an HTTP response to be returned to the requestor

After adding the class, rebuild the application and go to <http://localhost:8080/>. You should see "Hello from Spring Boot" displayed in the browser.

```bash
mvn clean package
mvn spring-boot:run
```
## A Note About Deployment to Azure
Building out Infrastructure as Code is worthy of a complete tutorial, but I don't want to pull you down that rabbit hole since it's likely to distract from the main topic of this learning journey. Throughout the journey, a [Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) template for provisioning infrastructure and [GitHub Action](https://docs.github.com/en/actions) workflow will be progressively built out to support what is happening in the application. The Bicep template can be found in the repo at `src/main/az/main.bicep` and the Github workflow at `.github/workflows/maven-publish.yml`.

If you plan to use the provided GitHub workflow, please review <https://github.com/marketplace/actions/azure-login#configure-deployment-credentials> for important information on how to set up an identity in Azure that can be used to deploy your application. You will *need* to [create a secret](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md) in your GitHub repository called `AZURE_CREDENTIALS` for the workflow to successfully execute.

If you choose not to use the provided templates, I will at each stage describe infrastructure and relevant settings being deployed, but YMMV and you may find that much less time is spent debugging if you use the provided templates.

## Deploying the Basic App
With a tested and working application packaged into your JAR file, it's time to deploy the application to Azure. I created the following resources (with relevant settings) into a single [Azure Resource Group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group) which allows me to easily clean up the solution by deleting the resource group and all of its contents:

- [Log Analytics Workspace](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview)
  - "Per Gigabyte (2018)" pricing tier
- [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
  - Connected to Log Analytics Workspace above
- [App Service Plan](https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans)
  - Linux operating system
  - `B1` SKU for pricing
- [App Service](https://docs.microsoft.com/en-us/azure/app-service/overview)
  - Connected to above App Service Plan
  - Code deployment (not container)
  - Java 11 runtime stack
  - Healthcheck URL set to /actuator/health

With the infrastructure deployed, the application can be deployed to the App Service using the following CLI command (replacing the bracketed values with your own):
```bash
az webapp deploy --resource-group <YOUR_RG_NAME> --name <YOUR_WEBSITE_NAME> --src-path ./target/app.jar
```

With infrastructure provisioned and code deployed, explore your deployed App Service and Application Insights.

## Checkpoint
At this point, you've created a simple Spring Boot Application and deployed it into Azure App Service. All of the stated success criteria have been demonstrated with the exception of "no secrets in source control" because up until this point the application has not needed any secrets. We'll build that into the application in our next installment!

## Keeping secrets out of source control
>
> Please note that this section contains a *very* contrived example. We will be
> demonstrating that we're able to store and use a "secret" by divulging that secret
> to visitors of our website. Obviously I am not advocating for having your applications
> divulge your secret values, but I figured it's safer to mention that than to assume that
> it's self-evident :)
>
### Why Environment Variables
Now that we have a working minimal application, the next step towards making the application useful is to learn how to deal with environment variables and secrets. Having secrets stored in source control, even temporarily, has been the root cause of many major security incidents over the years. Because this is such a big deal, I am a huge proponent of the idea that even for sample and POC applications we as responsible developers should develop a habit of *never* hard coding secrets. It doesn't take that much additional effort to use environment variables and once the habit is formed, deployment of our application into Azure allows us a lot of flexibility into how the environment variable is eventually populated at runtime.

Besides the security implications of secrets in source control, there are also maintainability reasons to use environment variables for secrets and configuration elements that may vary by deployment environment. If you take design inspiration from 12 Factor App concepts, then you may be familiar with the idea of [storing config in the environment](https://12factor.net/config) so that you can achieve [one codebase, many deploys](https://12factor.net/codebase). I am not going to recreate that work here, but it is well worth reading and quite brief.

### Set up for environment variables
Environment variables needed for this tutorial have been added to the file `.env.example` in the repository root. Additionally, the shell script `import-environment.sh` has been set up to import environment variables from a file called `.env`. My recommendation is to copy the `.env.example` file to `.env` and make any desired changes to variable values (leaving the variable name intact). The `.env` file is included in the gitignore for this repository in order to reduce the chance that secrets used during development and debugging will inadvertantly be committed to source control. After setting up your `.env` file, run the following:

```bash
chmod +x import-environment.sh
./import-environment.sh
```

> NOTE: if you're using Windows for development, you will need to manually create
> any environment variables or write your own script to import `.env`

### Adding the Secret controller
With the `MY_SECRET_VALUE` environment variable in place, it's time to create code to consume the variable in your application. Create `src/main/java/com/kyleburnsdev/SecretController.java` and add the following code:

```java
package com.kyleburnsdev;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(path="/secret")
public class SecretController {
    @Value("${MY_SECRET_VALUE}")
    private String mySecret;

    @GetMapping
    public @ResponseBody String tellSecret() {
        return String.format("The secret value is %s", mySecret);
    }
}
```

The important piece of this code in relation to the secrets if the use of the `@Value` annotation on the private `mySecret` field, which instructs Spring Boot to inject the value of the `MY_SECRET_VALUE` environment variable.

After adding the class, rebuild the application and go to <http://localhost:8080/secret>. You should see the value of the environment variable displayed in the message.

### Setting up the Azure environment
#### Application Setting
To get our Azure environment set up requires exposing the `MY_SECRET_VALUE` environment variable to your code at runtime. In Azure App Service, this is accomplished by adding an application setting with the same name. Details on how to accomplish this can be found at <https://docs.microsoft.com/en-us/azure/app-service/configure-common>.

Once the application setting is configured, navigate to the new `/secret` endpoint of your application and observe that the value of the environment variable is included in the message display.

#### Key Vault
For many applications, just keeping the secrets out of source control isn't enough. [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview) allows for complete management of secrets and certificates used by your application. The tutorial at <https://docs.microsoft.com/en-us/azure/key-vault/general/tutorial-net-create-vault-azure-web-app> shows how to set up a KeyVault, grant permission to the App Service to read secrets, and add Key Vault client code to a .NET Core application. This is a good exercise, but I strongly prefer an approach that doesn't include explicit Key Vault client code in the application because I favor an approach that leaves the consuming application unaware that Key Vault even exists. My preference to avoid explicit Key Vault code in the application is why the technique described in the [Use Key Vault references](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references) how-to article was selected for this application.

> NOTE: please use the above mentioned articles for details on how to create Key Vault and keys as well as how to appropriately set permissions

To complete the Key Vault integration for your application secrets, complete the following:
- Configure your Web App to [use a System Assigned Managed Identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=portal%2Chttp#add-a-system-assigned-identity)
- Ensure that you have set up a Key Vault
- Add a secret named `mysecret`. Use any value that you would like and content type of `text/plain`
- Grant the web application identity access to the Key Vault with the rights to get and list secrets
- Update the `MY_SECRET_VALUE` application setting to use a keyvault reference. The value of the application setting should look like (don't forget to replace the Key Vault name):
```
@Microsoft.KeyVault(VaultName=YOUR_KEY_VAULT_NAME;SecretName=mysecret)
```

With the Key Vault reference set up, go back to the `/secret` endpoint of your application and see that the value is being retrieved. Key Vault references update about every 24 hours and when the application restarts, so if you update your secret and want to see the update reflected immediately in the application, you will need to restart the application manually.

## Checkpoint
We have now together built a simple application that demonstrates all of the initial success criteria. Over time, this sample may evolve to take on additional success criteria as I need to gain additional depth in Spring Boot.
