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
    <version>2.1.0.RELEASE</version>
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
Our project still has no classes defined, so we are going to add a class that will serve as the entry point to the application. [Application.java] (src/main/java/com/kyleburnsdev/Application.java) is created in the folder structure under the java src directory and a subfolder structure to match the namespacing of the class. Documentation on the SpringApplication annotation and classes decorated with it can be found in the official [Spring Documentation] (https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-spring-application.html). The full path to the file is `src/main/java/com/kyleburnsdev/Application.java`.

A couple of important things to note at this point:

- Spring Boot requires classes to declare namespaces for it auto-configuration to work
- Maven is driven heavily by convention, so using the expected folder structure will help keep you on the path to success and deciding that you like your own convention better is possible but will cause a lot of unnecessary pain in the process

### Test the changes

With these changes in place, you should be able to use Maven to create an updated package and execute that package from the command line

```bash
mvn clean package
java -jar target/app.jar
```

The output will include a Spring Boot banner and if it reports success you will be able to navigate to http://localhost:8080 where you will see a page marked "Whitelabel Error Page"
