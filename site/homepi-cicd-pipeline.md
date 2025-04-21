# [Fareed R](./index.md)


# CI/CD and IaC on a Raspberry Pi


![*A CI/CD pipeline may seem like a [Rube Goldberg machine](https://en.wikipedia.org/wiki/Rube_Goldberg_machine) if you don't know the motivations that cause these practices to be widely used nowadays.*](./images/ci-cd-raspberry-pi-terraform-kubernetes.jpg)

# Table of Contents {#table-of-contents}

[**Table of Contents	1**](#table-of-contents)

[**1\. Introduction	1**](#1.-introduction)

[1.1. Motivations	1](#1.1.-motivations)

[1.2. Glossary	2](#1.2.-glossary)

[1.3. Goals of this Tutorial	3](#1.3.-goals-of-this-tutorial)

[1.4. Topics Covered	3](#1.4.-topics-covered)

[1.5. Solution Description	4](#1.5.-solution-description)

[**2\. Preparing the Pi	5**](#2.-preparing-the-pi)

[2.1. Get Raspbian Running off SSD	5](#2.1.-get-raspbian-running-off-ssd)

[2.2. Enable SSH on the Pi	5](#2.2.-enable-ssh-on-the-pi)

[2.3. Make Your Pi Accessible	6](#2.3.-make-your-pi-accessible)

[2.4. Secure the Raspberry Pi Manually	6](#2.4.-secure-the-raspberry-pi-manually)

## 1\. Introduction {#1.-introduction}

This project is a step-by-step tutorial that introduces basic concepts of modern CI/CD pipelines by creating a useful end-to-end system that is secure and deploys to a lightweight server being a Raspberry Pi 5 available through a public IP.

### 1.1. Motivations {#1.1.-motivations}

Connected applications are expected to encompass availability, scalability, maintainability, impenetrability, testability and reliability amongst a host of other abilities. Traditionally, deployment of these applications was a tedious and manual process prone to a multitude of human errors which could be as simple as the skipping of crucial tests or missing a key security configuration leading to disruptions to users potentially dealing a fatal blow to organizational objectives.

Modern applications are served using complex infrastructures that include cloud paradigms with entire businesses critically dependent upon the smooth deployment and reliable delivery of services. The complex, security-sensitive and sometimes vendor-dependent configuration required to utilize infrastructure-as-a-service makes manual configuration very difficult and cumbersome to reproduce reliably. Infrastructural dependencies required by a server can soon become obsolete requiring reconfiguration and redeployment.

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
  * The actual website is coded not in HTML but markdown which makes the Github repository the application is hosted on a very simple and flexible CMS. I write these articles on Google Drive documents and it features downloading these documents in markdown format.  
  * A Dockerfile configuration specifies pulling a NGINX base image and executing a bash script that converts the markdown content with links to HTML to be served.  
  * GitHub Actions is again used to execute the CI/CD pipeline which builds a Docker image using a Dockerfile and pushes the image to Docker.io which in-turn is pulled by the K3s cluster and served.  
* Next steps that are not part of the tutorial but will be covered in further posts which will include:  
  * Exploring and using ArgoCD or similar GitOps tool for automatic deployments of applications.  
  * Creating, deploying and running a Golang API server with a Mongodb backend that serves a REST API that is used by the web application.

## 2\. Preparing the Pi {#2.-preparing-the-pi}

Note that I will assume that you have a Linux-based system or a Mac. For instructions on other OS, please use [ChatGPT](https://chatgpt.com/) or other LLM if you don’t feel lucky enough to [Google](https://google.com).

### 2.1. Get Raspbian Running off SSD {#2.1.-get-raspbian-running-off-ssd}

I used an [Argon NEO 5 M.2 NVME PCIE Case for Raspberry Pi 5](https://shop.pimoroni.com/products/argon-neo-5-m-2-nvme-pcie-case-for-raspberry-pi-5) to keep the Pi cool under load as it is to be used as a server after all. The Pi is connected to my home router using an ethernet cable. The latest version of Raspbian was used which included the X server as I wanted to explore the capabilities of the Raspberry Pi 5 as a desktop replacement too. However, I rarely use the Raspberry Pi as such. I ssh into the Pi for any configuration and even that is happening increasingly rare because that’s the work of the CI/CD pipeline. You could go with a headless setup if you so desire with just a bare minimal OS to function as a server. When running Raspbian from an SSD, I got disk reads of about 865 MB/s using `sudo hdparm -t /dev/nvme0n1`. We won’t delve into details on how to go about doing this as there are enough tutorials that will help you get Raspbian booting from SSD.

Note that you may require to reset your Raspberry Pi to a fresh state multiple times as you go through this tutorial to understand the automated application of configuration you may first attempt manually to understand the underlying concept that needs to be automated.

### 2.2. Enable SSH on the Pi {#2.2.-enable-ssh-on-the-pi}

It is recommended that you change the root password of the Raspberry Pi with:  
`sudo su - ; sudo passwd;`

You can enable SSH with password login when installing Raspbian or later with:  
`sudo systemctl enable ssh`  
`sudo systemctl start ssh`

Create an SSH key pair on your local machine (not the Pi) using  
`ssh-keygen -t ed25519 -C “your_email_addr@domain.com”`

You will find the public and private key pair file at \~/.ssh/id\_ed25519. There will be two files:

* Public key: \~/.ssh/id\_ed25519.pub  
* Private key: \~/.ssh/id\_ed25519

Copy the public key to the Raspberry Pi using ssh as below:  
`ssh-copy-id -i ~/.ssh/id_ed25519.pub username@<raspberry-pi-ip>`

This keypair will be used to perform actions using Ansible or Terraform using our local machine or later to store as Github Actions secrets thus allowing the Github actions runner to ssh into the Raspberry Pi to perform actions on our behalf.

### 2.3. Make Your Pi Accessible {#2.3.-make-your-pi-accessible}

You should find out the mac address of your Pi and provide it a static IP address using your home router configuration. You will need a public IP to host services and most ISPs enable this for a fee on request. After you obtain a public IP from your ISP, you should forward ports 22, 80 and 443 to the static IP address of your Raspberry Pi on your LAN. It is recommended that you purchase a domain and setup the following DNS records:

* A record  
* Alias

### 2.4. Secure the Raspberry Pi Manually {#2.4.-secure-the-raspberry-pi-manually}

We will be using Ansible for post-OS install provisioning and system configuration of the Raspberry Pi automatically. However, it is important to gain a good understanding of the tasks we wish to automate and thus we will first attempt security hardening of our server manually prior to automating it.

Disable password login on the Pi by editing the /etc/ssh/sshd\_config file with:  
`sudo nano /etc/ssh/sshd.config`

Ensure these lines are set to ensure that only public key authentication is possible and root login is disabled under any circumstances.

`PasswordAuthentication no`  
`ChallengeResponseAuthentication no`  
`UsePAM no`  
`PermitRootLogin no`  
`PubkeyAuthentication yes`

Restart SSH:  
`sudo systemctl restart ssh`

We must ensure that only the ports required are enabled on the Raspberry Pi. Initially we would require only port 22 for SSH to be accessible. For this, we will use UFW (Uncomplicated Firewall) that has a simple configuration syntax and it makes managing iptables more user-friendly. Unnecessary Pi ports will most probably not be exposed through the home router port-forwarding but installing a firewall is nevertheless a good practice on any server.

1. Install UFW

`sudo apt update`  
`sudo apt install ufw -y`

2. Set default policies

Block incoming connections unless they match an explicit rule:  
`sudo ufw default deny incoming`

Allow Pi to initiate outgoing connections:  
`sudo ufw default allow outgoing`

3. Allow TCP traffic on required ports

Port 22 (SSH), 80 (HTTP) & 443 (HTTPS):

`sudo ufw allow 22/tcp`  
`sudo ufw allow 80/tcp`  
`sudo ufw allow 442/tcp`

Later we can enable another port for calling the API to control the K8s cluster.

4. Enable UFW

`sudo ufw enable`

This will ask you to confirm if you want to enable as this will disrupt your current ssh session. Since you have allowed ssh, confirm by pressing ‘y’.

5. Check the status of UFW rules

`sudo ufw status numbered`

`Status: active`  
`To                         Action      From`  
`--                         ------      ----`  
`[ 1] 22/tcp                     ALLOW IN    Anywhere`                    
`[ 2] 80/tcp                     ALLOW IN    Anywhere`                    
`[ 3] 443/tcp                    ALLOW IN    Anywhere`                    
`[ 4] Anywhere                   DENY IN     Anywhere`                    
`[ 5] 22/tcp (v6)                ALLOW IN    Anywhere (v6)`               
`[ 6] 80/tcp (v6)                ALLOW IN    Anywhere (v6)`               
`[ 7] 443/tcp (v6)               ALLOW IN    Anywhere (v6)`               
`[ 8] Anywhere (v6)              DENY IN     Anywhere (v6)` 

6. Optional IP whitelisting

Optionally for extra security you can restrict ssh access to only a whitelisted IP address with the below command.   
`ufw allow from <IP address> to any port 22 proto tcp`

However, it will require deletion of the rule added to allow access from 22 from anywhere with:  
`ufw delete <rule number>`

7. Logout and ssh again to confirm rules work

8. Enable logging for blocked traffic

`sudo ufw logging on`  
`sudo ufw logging medium`

Logs can be checked with:  
`sudo journalctl | grep UFW`  
`sudo journalctl -u ufw -n 20`

These are only the first steps in preparing your Raspberry Pi. Imagine you had a hundred such server machines to configure on an in-prem data center or VMs on a cloud. Here is where Ansible can help us automate configuration and installation of servers wholesale.


# [< Back to Fareed R](./index.md)
