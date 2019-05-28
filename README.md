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

### Visual Studio Code

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
