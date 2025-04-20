# [Fareed R](./index.md)


# CI/CD and IaC on a Raspberry Pi


![*A CI/CD pipeline may seem like a [Rube Goldberg machine](https://en.wikipedia.org/wiki/Rube_Goldberg_machine) if you don't know the motivations of why these practices are widely used nowadays.*](./images/ci-cd-raspberry-pi-terraform-kubernetes.jpg)


# Table of Contents {#table-of-contents}

[**Table of Contents**](#table-of-contents)

[**1\. Introduction**](#1.-introduction)

[**1.1. Motivations**](#1.1.-motivations)

[**1.2. Glossary**](#1.2.-glossary)

[**1.3. Goals of this Tutorial**](#1.3.-goals-of-this-tutorial)

[**1.4. Topics Covered**](#1.4.-topics-covered)

[**1.5. Solution Description**](#1.5.-solution-description)

---

## 1\. Introduction {#1.-introduction}

This project is a step-by-step tutorial that introduces basic concepts of modern CI/CD pipelines by creating a useful end-to-end system that is secure and deploys to a lightweight server being a Raspberry Pi 5 available through a public IP.

### 1.1. Motivations {#1.1.-motivations}

Connected applications are expected to encompass availability, scalability, maintainability, testability and reliability amongst a host of other abilities. Traditionally, deployment of these applications was a tedious and manual process prone to a multitude of human errors which could be as simple as the skipping of crucial tests leading to disruptions to users which could potentially deal a fatal blow to organizational goals and objectives.

Modern applications are served using complex infrastructures that include cloud paradigms and entire businesses critically depend upon the smooth deployment and reliable delivery of services. The complex and sometimes vendor-dependent configuration required to utilize infrastructure-as-a-service makes manual configuration very difficult and cumbersome to reproduce reliably. Infrastructural dependencies required by a server can soon become obsolete requiring reconfiguration and redeployment.

Setups are required to be deployed with slight configuration variations in different environments as per stages of a software development lifecycle. With increasingly stricter security requirements, data isolation may be required with similar services deployed in data centers in individual operational countries. Deployments should be flexible and not cloud-vendor locked and due to financial incentives, may require to near-seamlessly shift to another cloud provider altogether. The repeatability of operations requires spot-on accuracy with very less tolerance for mistakes for ensuring business continuity.

Thus lately, the continuous integration and delivery of applications is treated like a first-class citizen in forward-thinking organizations embracing the DevOps movement.

### 1.2. Glossary {#1.2.-glossary}

**CI/CD (Continuous Integration / Continuous Delivery)**  
The discipline of merging code frequently such that it is automatically built, tested and deployed in various environments from development to production such that mostly software served through the Internet is delivered continuously.

**IaC (Infrastructure as Code)**  
Description of deployed infrastructure in a declarative language to automatically and precisely replicate steps to be taken for deploying infrastructure like servers, networks, Kubernetes clusters etc.

**CMS (Content Management System)**  
A software system used to manage the creation and modification of digital content.

**SSH (Secure Socket Shell)**  
A network protocol used to securely access a Linux machine remotely and execute commands on it.

**UFW (Uncomplicated Firewall)**  
A frontend for iptables to make netfilter firewall configuration more user-friendly.

**Ansible**  
An open source IT automation engine that automates provisioning, configuration management, application deployment, orchestration, and many other IT processes.

**Docker Container Image**  
A standard, lightweight, standalone, executable package of software that includes everything needed to run an application as a container at runtime.

**Dockerfile**  
A text document that contains all the commands a user could call on the command line to assemble a container image.

**Kubernetes (K8s)**  
An open source system for automating deployment, scaling and management of containerized applications.

**k3s**  
A highly available, certified Kubernetes distribution designed for production workloads in resource-constrained servers optimized for ARM.

**Helm**  
A package manager for Kubernetes that uses charts that are templatized and shared configuration that make it easy to deploy complex Kubernetes applications comprising of multiple resources.

**Pod**  
The smallest deployable units of computing comprising of one or more containers that can be created and managed in Kubernetes.

### 1.3. Goals of this Tutorial {#1.3.-goals-of-this-tutorial}

* To learn modern CI/CD pipeline practices by practical application without spending a ton of money on deploying on cloud services.  
* Possess a lightweight services development and prototyping platform on a minimalist hardware that utilizes very little power \- a Raspberry Pi 5 in this case.  
* Host a website with a simple CMS as the first application showcasing and deployed by the IaC based CI/CD pipeline.

### 1.4. Topics Covered {#1.4.-topics-covered}

* Basic Linux server configuration using Ansible with basic configuration like SSH running on the Pi with key-based authentication, firewall etc.  
* GitHub Actions as a IaC runner and a CI/CD pipeline runner.  
* Terraform for declaring K8s cluster servers with state managed in Terraform cloud.  
* Building Docker images, publishing them and serving them off Docker cloud.  
* Kubernetes with practical usage of many container orchestration concepts.  
* Security wherever applicable like using GitHub actions to store secrets, TLS with certificates, SSH key-based authentication etc.

### 1.5. Solution Description {#1.5.-solution-description}

We will create an IaC solution that uses declarative language to create a base for quick and easy deployment of many application servers on a Raspberry Pi 5 (or any hardware for that matter). Don’t worry if you don’t yet understand the terminology here. The goal of this tutorial is to demystify all of it and open a path for further exploration and self-mastery of the topics covered here.  
 
* Complete remote installation and configuration once a Raspbian image has been copied on SSD with the pipeline running on Github Actions that sets up the below.  
  * Ansible playbook used for configuration of the Pi 5 which includes:  
    * Key-based ssh login enabled on the Pi 5 and public key copied securely into Github Actions secrets.  
    * Pi secured using UFW with only required ports for incoming connections.  
    * Installation of Kubernetes for application deployment and copying of k3s into Github Actions container.  
  * Terraform pipeline that sets up K3s Kubernetes single-node cluster for applications:  
    * The state of deployment stored in Terraform Cloud.  
    * Install NGINX ingress controller using a Helm chart.  
    * Install TLS certificate management infrastructure with Letsencrypt.  
    * Deploy the profile web application from a container hosted on Docker.  
* A profile web application deployed with a simple CMS with an unique method.  
  * The actual website is coded not in HTML but markdown which makes the Github repository the application is hosted on a very simple and flexible CMS.  
  * A Dockerfile configuration specifies pulling a NGINX base image and executing a bash script that converts the markdown content with links to HTML to be served.  
  * GitHub Actions is again used to execute the CI/CD pipeline which builds a Docker image using a Dockerfile and pushes the image to Docker.io which in-turn is pulled by the K3s cluster and served.  
* Next steps that are not part of the tutorial but will be covered in further posts which will include:  
  * Exploring and using ArgoCD or similar GitOps tool for automatic deployments of applications.  
  * Creating, deploying and running a Golang API server with a Mongodb backend that serves a REST API that is used by the web application.



# [< Back to Fareed R](./index.md)
