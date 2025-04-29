# [Fareed R](./index.md)


# CI/CD and IaC on a Raspberry Pi


![*A CI/CD pipeline may seem like a [Rube Goldberg machine](https://en.wikipedia.org/wiki/Rube_Goldberg_machine) if you don't know the motivations that cause these practices to be widely used nowadays.*](./images/ci-cd-raspberry-pi-terraform-kubernetes.jpg)

# Table of Contents {#table-of-contents}

[**1\. Introduction**](#1.-introduction)

[1.1. Motivations](#1.1.-motivations)

[1.2. Glossary](#1.2.-glossary)

[1.3. Goals of this Tutorial](#1.3.-goals-of-this-tutorial)

[1.4. Topics Covered](#1.4.-topics-covered)

[1.5. Solution Description](#1.5.-solution-description)

[1.6. Source Code](#1.6.-source-code)

[**2\. Preparing the Pi**](#2.-preparing-the-pi)

[2.1. Get Raspbian Running off SSD](#2.1.-get-raspbian-running-off-ssd)

[2.2. Enable SSH on the Pi](#2.2.-enable-ssh-on-the-pi)

[2.3. Make Your Pi Accessible](#2.3.-make-your-pi-accessible)

[2.4. Secure the Raspberry Pi Manually](#2.4.-secure-the-raspberry-pi-manually)

[**3\. Ansible Playbook Run on GitHub Actions**](#3.-ansible-playbook-run-on-github-actions)

[3.1. Run Ansible from the Local Machine](#3.1.-run-ansible-from-the-local-machine)

[3.2. Introduction to GitHub Actions](#3.2.-introduction-to-github-actions)

[3.3. Execute the Ansible Playbook from GitHub Actions](#3.3.-execute-the-ansible-playbook-from-github-actions)

[**4\. Profile Web Application**](#4.-profile-web-application)

[4.1. (Minimalist) Web Application Architecture](#4.1.-minimalist-web-application-architecture)

[4.2. Markdown and Conversion](#4.2.-markdown-and-conversion)

[4.3. Docker Container Introduction](#4.3.-docker-container-introduction)

[4.4. Building the Application Image](#4.4.-building-the-application-image)

[4.5. Application CI/CD Pipeline](#4.5.-application-ci-cd-pipeline)


[**5\. Kubernetes**](#5.-kubernetes)

[5.1. Introduction to Kubernetes](#5.1.-introduction-to-kubernetes)

[5.2. Basic Kubernetes Concepts](#5.2.-basic-kubernetes-concepts)

[5.3. Installation of k3s Cluster](#5.3.-installation-of-k3s-cluster)

[5.4. Manual Configuration of Web Application Pods](#5.4.-manual-configuration-of-web-application-pods)

[5.5. High-Level Architecture of Workload](#5.5.-high-level-architecture-of-workload)

[**6\. Terraform**](#6.-terraform)

[6.1. Terraform Introduction](#6.1.-terraform-introduction)

[6.2. Basic Terraform Concepts](#6.2.-basic-terraform-concepts)

[6.3. Terraform Creation of Workload](#6.3.-terraform-creation-of-workload)

[6.4. Terraform Bootstrapping](#6.4.-terraform-bootstrapping)

[6.5. Basic Terraform Test](#6.5.-basic-terraform-test)

[6.6. Completed IaC Pipeline](#6.6.-completed-iac-pipeline)

[**7\. Final Thoughts**](#7.-final-thoughts)

---

## 1\. Introduction {#1.-introduction}

This project is a step-by-step tutorial that introduces basic concepts of modern CI/CD pipelines by creating a useful end-to-end system that is secure and deploys to a lightweight server being a Raspberry Pi 5 available through a public IP.

### 1.1. Motivations {#1.1.-motivations}

Connected applications are expected to encompass availability, scalability, maintainability, impenetrability, testability and reliability amongst a host of other abilities. Traditionally, deployment of these applications was a tedious and manual process prone to a multitude of human errors which could be as simple as the skipping of crucial tests or missing a key security configuration leading to disruptions to users potentially dealing a fatal blow to organizational objectives.

Modern applications are served using complex infrastructures that include cloud paradigms with entire businesses critically dependent upon the smooth deployment and reliable delivery of services. The complex, security-sensitive and sometimes vendor-dependent configuration required to utilize infrastructure-as-a-service makes manual configuration very difficult and cumbersome to reproduce reliably. Infrastructural dependencies required by a server can soon become obsolete requiring reconfiguration and redeployment.

Setups are required to be deployed with slight configuration variations in different environments as per stages of a software development lifecycle. With increasingly stricter security requirements, data isolation may be required with similar services deployed in data centers in individual operative countries. Deployments should be flexible and not cloud-vendor locked and due to financial incentives, may require to near-seamlessly shift to another cloud provider altogether. The repeatability of operations requires spot-on accuracy with very less tolerance for mistakes for ensuring business continuity.

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

**Terraform**  
An IaC tool that allows for building, changing and versioning infrastructure which can include components like compute instances, storage, and networking; and high level components like DNS entries.

### 1.3. Goals of this Tutorial {#1.3.-goals-of-this-tutorial}

* To learn modern CI/CD pipeline practices by practical application without spending a ton of money on deploying on cloud services.  
* Possess a lightweight services development and prototyping platform on a minimalist hardware that utilizes very little power - a Raspberry Pi 5 in this case.  
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
 

* Complete remote installation and configuration once a Raspbian image has been copied on SSD with the pipeline running on GitHub Actions that sets up the below.  
  * Ansible playbook used for configuration of the Pi 5 which includes:  
    * Key-based ssh login enabled on the Pi 5 and public key copied securely into GitHub Actions secrets.  
    * Pi secured using UFW with only required ports for incoming connections.  
    * Installation of Kubernetes for application deployment and copying of k3s into GitHub Actions container.  
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

### 1.6. Source Code {#1.6.-source-code}

The repositories of the source code for this tutorial are at:

* [https://github.com/fareed1983/homepi](https://github.com/fareed1983/homepi) - The core Raspberry Pi IaC.  
* [https://github.com/fareed1983/profile](https://github.com/fareed1983/profile) - The profile website with a CI/CD workflow.

You are encouraged to note the commit history as I started as a noob and you can follow how my understanding grew as I progressed.

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

You will find the public and private key pair file at ~/.ssh/id_ed25519. There will be two files:

* Public key: ~/.ssh/id_ed25519.pub  
* Private key: ~/.ssh/id_ed25519

Copy the public key to the Raspberry Pi using ssh as below:  
`ssh-copy-id -i ~/.ssh/id_ed25519.pub username@<raspberry-pi-ip>`

This keypair will be used to perform actions using Ansible or Terraform using our local machine or later to store as GitHub Actions secrets thus allowing the Github actions runner to ssh into the Raspberry Pi to perform actions on our behalf.

### 2.3. Make Your Pi Accessible {#2.3.-make-your-pi-accessible}

You should find out the mac address of your Pi and provide it a static IP address using your home router configuration. You will need a public IP to host services and most ISPs enable this for a fee on request. After you obtain a public IP from your ISP, you should forward ports 22, 80 and 443 to the static IP address of your Raspberry Pi on your LAN. It is recommended that you purchase a domain and setup the following DNS records:

* A record  
* Alias

### 2.4. Secure the Raspberry Pi Manually {#2.4.-secure-the-raspberry-pi-manually}

We will be using Ansible for post-OS install provisioning and system configuration of the Raspberry Pi automatically. However, it is important to gain a good understanding of the tasks we wish to automate and thus we will first attempt security hardening of our server manually prior to automating it. We will later automate almost all of the steps below.

We must ensure that only the ports required are enabled on the Raspberry Pi. Initially we would require only port 22 for SSH to be accessible. For this, we will use UFW (Uncomplicated Firewall) that has a simple configuration syntax and it makes managing iptables more user-friendly. Unnecessary Pi ports will most probably not be exposed through the home router port-forwarding but installing a firewall is nevertheless a good practice on any server.

Step 1: Install UFW

`sudo apt update`  
`sudo apt install ufw -y`

Step 2: Set default policies

Block incoming connections unless they match an explicit rule:  
`sudo ufw default deny incoming`

Allow Pi to initiate outgoing connections:  
`sudo ufw default allow outgoing`

Step 3: Allow TCP traffic on required ports

Port 22 (SSH), 80 (HTTP) & 443 (HTTPS):

`sudo ufw allow 22/tcp`  
`sudo ufw allow 80/tcp`  
`sudo ufw allow 442/tcp`

Later we can enable another port for calling the API to control the K8s cluster.

Step 4: Enable UFW

`sudo ufw enable`

This will ask you to confirm if you want to enable as this will disrupt your current ssh session. Since you have allowed ssh, confirm by pressing ‘y’.

Step 5: Check the status of UFW rules

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

Optional Configuration:

Optionally for extra security you can restrict ssh access to only a whitelisted IP address with the below command.   
`ufw allow from <IP address> to any port 22 proto tcp`

However, it will require deletion of the rule added to allow access from 22 from anywhere with:  
`ufw delete <rule number>`

You an enable logging for blocked traffic.

`sudo ufw logging on`  
`sudo ufw logging medium`

Logs can be checked with:  
`sudo journalctl | grep UFW`  
`sudo journalctl -u ufw -n 20`

Step 6: Disable other login methods on the Pi

Edit the /etc/ssh/sshd_config file with:  
`sudo nano /etc/ssh/sshd.config`

Ensure these lines are set to ensure that only public key authentication is possible and other login methods including root login is disabled under any circumstances.

`PasswordAuthentication no`  
`ChallengeResponseAuthentication no`  
`UsePAM no`  
`PermitRootLogin no`  
`PubkeyAuthentication yes`

Step 7: Restart SSH  
`sudo systemctl restart ssh`

## 3\. Ansible Playbook Run on GitHub Actions {#3.-ansible-playbook-run-on-github-actions}

We have performed the first steps in preparing your Raspberry Pi manually. Imagine you had a hundred such server machines to configure on an in-prem data center or VMs on a cloud. Here is where Ansible can help us automate configuration and installation of servers wholesale. As an exercise, try to reverse the steps you already performed to understand your success in replicating the processes for automatic configuration in this section. We will create an Ansible pipeline which will automate the manual security configuration you did in section 2.4 and install k3s in later sections. We will first run the automation from our local machine by executing Ansible on the command-line and subsequently we will automate the pipeline to execute as a GitHub Actions runner when changes are done on the pipeline and pushed to your Github repository.

### 3.1. Run Ansible from the Local Machine {#3.1.-run-ansible-from-the-local-machine}

The first concept to grasp is the Ansible inventory file. This contains the inventory of hosts, also called nodes, and their groups which have to be configured. Individual variables can also be defined on the hosts and nodes for flexible automation. The inventory can be statically defined in the file or can be pulled from external sources dynamically. We will only concern ourselves with the static inventory of one Raspberry Pi node that we will configure.

Make an ansible/inventory.yml file with the following contents:

```
---  
raspberrypi:  
  hosts:  
    pi:  
      ansible_host: "{{ lookup('env','PI_HOST') }}"  
      ansible_user: "{{ lookup('env','PI_USER') }}"  
      ansible_port: "{{ lookup('env','PI_SSH_PORT') }}"
```

The PI_HOST, PI_USER and PI_SSH_PORT variables can be exported locally if you run the Ansible playbook from your local machine and later added as a secret into GitHub Actions. Use the DNS or IP as the host. For the port, use the default SSH port which is 22 or another if you are using a non-default port and the name of your user on the Raspberry Pi. Ansible will use these variables to ssh into your raspberry Pi and run commands on your behalf.

Credentials will be required for Ansible to ssh into the Raspberry Pi and execute commands and the keypair you generated earlier will be used. 

Let’s start making the initial Ansible Playbook. Create a file called ansible/playbooks/setup_pi.yml and add the following content. Note that YAML is very strict in indentation.

```
---	# Indicates YAML file start  
- name: Configure Raspberry Pi	# Defines the name of the play  
 hosts: raspberrypi	# Run the tasks on host defined in the inventory  
 become: true		# Run all tasks with sudo  
 vars:			# Lookup PI_HOST from the env and store it in pi_host  
   pi_host: "{{ lookup('env', 'PI_HOST') }}"

 tasks:  
   - name: Ensure apt is updated  
     apt:		# Update package index and upgrade installed packages  
       update_cache: yes  
       upgrade: dist  
    
   - name: Ensure UFW is installed  
     apt:			# apt is a module in Ansible   
       name: ufw	# Install ufw using apt if not already installed  
       state: present

   - name: Allow only some ports via UFW  
     ufw:			# Configure ufw  
       rule: allow			  
       direction: in	# Allow incoming port  
       port: "{{ item }}"	# {{ item }} gets replaced with each item  
       proto: tcp  
     with_items:		# Allows looping through values  
       - '22'  
       - '80'  
       - '443'

   - name: Default deny incoming  
     ufw:		# Deny all incoming ports on UFW except the above  
       rule: deny  
       direction: in  
    
   - name: Enable UFW  
     ufw:		# Note that ufw is a module in Ansible  
       state: enabled

   - name: Setting secure SSH options  
     lineinfile:		# Ensures line matches in a file or replaces  
       path: /etc/ssh/sshd_config  
       regexp: "^#?{{ item.option }}"	# Match this if changes required  
       line: "{{ item.option }} {{item.value}}"  
       create: yes  
       backup: no		# Don’t create backup of the file  
     loop:			# Allows looping through key-value pairs  
       - { option: "PasswordAuthentication", value: "no" }  
       - { option: "ChallengeResponseAuthentication", value: "no" }  
       - { option: "UsePAM", value: "no" }  
       - { option: "PermitRootLogin", value: "no" }  
       - { option: "PubkeyAuthentication", value: "yes" }  
     notify: Restart SSH	# Triggers handler to restart SSH if changes made

 handlers:  
   - name: Restart SSH  
     service:  
       name: ssh  
       state: restarted
```

The steps should be relatively straightforward as it somewhat replicates what you did with the command-line earlier. To help go through our Ansible Playbook block-by-block, I have added comments to the code listing above.

Ansible comes packaged with modules that are units of work. Each task defined typically uses a module. Here we use the following modules: apt, ufw, linefile, service which are part of ansible.builtin module source/collection. You can specify the fully qualified name (FQCN) like ansible.builtin.linefile.

Many Ansible modules check the current state before making unnecessary changes. When a change is made, the task is marked as ‘changed’ otherwise it is ‘ok’. The notify directive in a task triggers a ‘handler’ if the task resulted in a change as illustrated with the ‘Restart SSH’ handler in our playbook.

As an exercise, use the following commands to learn about each module we use with documentation available through the command-line or online. Below are some helpful commands to help you on your quest:

* List all module collections: `ansible-galaxy collection list`  
* List modules installed: `ansible.doc -l`  
* Search modules by name: `ansible.doc -l | grep <name>`  
* Learn about a particular module: `ansible-doc apt`

We can run this Ansible playbook locally from your development machine by exporting the environment variables required. Install Ansible on your local machine as it will help you confirm that your Ansible playbook works and debug when required.

From the root, execute the following commands:  
`export PI_SSH_PORT=”22”`  
`export PI_HOST="<Pi’s host or IP>"`  
`export PI_USER="<Username on Pi>"`  
`ansible-playbook -i ansible/inventory.yml ansible/playbooks/setup_pi.yml`

This should execute the changes on your Raspberry Pi. You can manually undo changes as experiments and see if Ansible reapplies the desired state as per the Playbook.

### 3.2. Introduction to GitHub Actions {#3.2.-introduction-to-github-actions}

[GitHub Actions](https://docs.github.com/en/actions/about-github-actions/understanding-github-actions) allows custom CI/CD workflows to be executed on ‘runners’ when events occur on a code repository. The runner is a (Ubuntu, Windows or MacOS) [container image](https://github.com/actions/runner-images) that executes the GitHub workflow job. GitHub is very ‘generous’ and provides free compute resources as [GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/using-github-hosted-runners). Come to think of it, if it was not free, I would not use it and you would not be reading this. 2,000 minutes of free runner minutes are provided as part of the free plan and this should suffice for the needs of a learner. If you want more, you can buy paid plans or host runners privately if you prefer. 

GitHub Actions also offers such features as secure secret management that we will use to store credentials and other variables to be injected at runtime for use in our workflows.  
The private key should be accessible by the pipeline. For this, we create a secret in GitHub Actions. In your repo, go to Settings->Security->Actions->New repository secret and create a secret called SSH_PRIVATE_KEY. Copy the text contents of ~/.ssh/<private-key-file> as the value. Also create a secret with your Pi’s IP or domain name called PI_HOST.

### 3.3. Execute the Ansible Playbook from GitHub Actions {#3.3.-execute-the-ansible-playbook-from-github-actions}

Create a repo on Github for the CI/CD IaC pipeline. Commit the Ansible playbook there in the following directory structure:
```
 ├── README.md
 └── ansible
     ├── inventory.yml
     └── playbooks
         └── setup_pi.yml
```

We will listen to the commit event on the prod folder on the base infra repository which will trigger a workflow to run the Ansible playbook inside a GitHub Actions runner. To start, 

Then we will add environment variables that will be injected when the runner is executing the pipeline. In the GitHub repository web interface, click the settings icon and then expand “Secrets and variables” and enter “Actions”. We will add 1 variable and 3 secrets currently.

1. Select the variable tab and add “PI_HOST” with your domain name as the value. In my case it was fareed.digital that resolves to the IP of my Pi.  
2. Select the secrets tab and add the following:  
   1. “PI_USER” - The username that is a sudoer in your Pi.  
   2. “PI_SSH_PORT” - The port where SSH is enabled on your Pi (default is 22).  
   3. “SSH_PRIVATE_KEY” - Copy the contents of the private key from ~/.ssh/id_ed25519 that you generated earlier as the value to this variable.

Let’s create a github workflow to run this Ansible playbook. Create a file .github/workflows/ci-cd.yml. Add the following:


```
name: CI/CD for Raspberry Pi

on:  
  push:  
    branches: [ "main" ]

jobs:  
  build-deploy:  
    runs-on: ubuntu-latest  
    env:  
      PI_HOST: ${{ vars.PI_HOST }}  
      PI_USER: ${{ secrets.PI_USER }}  
      PI_SSH_PORT: ${{ secrets.PI_SSH_PORT }}

    steps:  
      - name: Check out repo  
        uses: actions/checkout@v4  
          
      - name: Setup SSH  
        uses: webfactory/ssh-agent@v0.9.0  
        with:  
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}  
    
      - name: Add Pi host key to known_hosts  
        run: |  
          mkdir -p ~/.ssh  
          ssh-keyscan -p $PI_SSH_PORT $PI_HOST  >> ~/.ssh/known_hosts  
          chmod 600 ~/.ssh/known_hosts

      - name: Install Ansible  
        run: |  
          sudo apt-get update  
          sudo apt-get install ansible -y

      - name: Run Ansible Playbook  
        run: |  
          ansible-playbook \
            -i ansible/inventory.yml \
            ansible/playbooks/setup_pi.yml
```

Explanation of the pipeline is as follows:

1. We create a pipeline for Github actions instructing it to trigger the job “build-deploy” on push to the main branch.   
2. We reference the envs from the GitHub Actions secrets and the variable that we added above to inject them into the runner as environment variables.  
3. The first ‘action’ it uses is actions/checkout@v4. The checkout action checks out the code from the repository into the workflow’s runner.   
4. We then add the SSH private key to the agent so that Ansible can connect to the Pi using key-based authentication. We also add the Pi’s SSH fingerprint to the known hosts to avoid asking for host authenticity confirmation because we cannot type ‘yes’ like we do on our local machine.  
5. The GitHub runner is barebone each time it is executed so we have to install Ansible using apt.  
6. Finally, we run the Ansible Playbook with the same command that we use locally.

Commit this to your repo to the default (main) branch and this should trigger the build-deploy job. You can also ssh into the Raspberry Pi before the job executes and run commands like `sudo ufw reset` to verify that the pipeline worked. You can validate the successful execution with `sudo ufw status numbered` on the Pi.

To watch your workflow runs, click on the Actions tab in your repository and it should show a job ran for your last commit because of the presence of the file .github/workflows/ci-cd.yml. You can click the job and explore the run in depth.


## 4\. Profile Web Application {#4.-profile-web-application}

### 4.1. (Minimalist) Web Application Architecture {#4.1.-minimalist-web-application-architecture}

The aim was to create a very simple content management system for simple articles with links and images. I realized that markdown was enough for my purposes and thus found that the utility [Pandoc](https://pandoc.org/), a universal document converter can convert markdown into HTML. This was the first article I published using this method. I actually am writing this article on Google Drive as a Google Doc which allows me to download the document as a markdown (md) file from which I copy-paste the relevant portions. I use VSCode to fine-tune the markdown produced and push it to the GitHub repository which triggers the CI/CD pipeline executed in a GitHub Actions runner. The pipeline executes a script that runs Pandoc and converts each md file into HTML and then copies the HTML and images into a NGINX docker image and then publishes the image to the Docker Hub container image library.

### 4.2. Markdown and Conversion {#4.2.-markdown-and-conversion}

[Markdown](https://en.wikipedia.org/wiki/Markdown) is a lightweight markup language for creating formatted text using a plain text editor. Most developers come across markdown when writing README.md files which are published as default as HTML on source code repository services. The markdown format was rebranded as CommonMark and adapted as a standard with [RFC 7763](https://www.rfc-editor.org/rfc/rfc7763.html) introducing a MIME type ‘text/markdown’. 

Common formatting options are as follows:

* \#Heading 1  
* \#\# Heading 2  
* \#\#\# Heading 3  
* \#\#\# Heading {\#custom-id}  
* \*\*Bold\*\*  
* \*Italics\*  
* \> BlockQuotes  
* \>\>\>\| BlockQuotes  
* \~\~Strikethrough  
* H\~2\~O - Subscript  
* a^2^ \+ b^2^ - Superscript  
* Highlight == important words ==  
* Footnote [^1]  
* [^1]Footnote description  
* [Link name]{[https://link.example.com](https://link.example.com)}  
* Ordered List (start with number ex. “1. First item”)  
* Unordered list (start with -)  
* Definition List  
* Term  
  :definition  
* Task List  
  -[x] Task done  
  -[] Task 2  
* Code blocks can be written like:  
  \`\`\`  
  someCode();  
  \`\`\`  
* Code can also be written with:  
  \`singleLineOfCode(a, b);  
* Horizontal line  
  - - -  
* Image: ![alt text](imageFile.png)  
* Table  
  |Name |Age |  
  |---------|-----|  
  |fareed|42  |  
* Latex can also be used and so can emojis

To look at how this webpage was made, head to the md file in the GitHub repo at [https://github.com/fareed1983/profile/blob/main/site/homepi-cicd-pipeline.md](https://github.com/fareed1983/profile/blob/main/site/homepi-cicd-pipeline.md) and view the “raw” version.

### 4.3. Docker Container Introduction {#4.3.-docker-container-introduction}

Virtualization was the answer to under-utilization of hardware resources by packing more server loads shared on the same physical server. In the early 2000s, server virtualization used hypervisors that emulated the entire machine with each guest OS running its own kernel. This allowed for strong isolation mixing different OSes. However, these virtual machines took a long time to boot up and consumed a lot of memory and CPU resources. 

With microservices taking center stage, the need arose for a lot more isolated servers that were continuously delivered and code changes were expected to reach production within minutes. Only an application and the user space libraries started being isolated while the underlying host kernel was shared. Docker was released in 2013 and soon instances of servers could be spawned consuming only a few megabytes of memory in milliseconds.

A Docker image is a template which can be executed running a container. The steps required to build the image are described in a Dockerfile. Each [instruction](https://docs.docker.com/reference/dockerfile/) in the Dockerfile (FROM, COPY, RUN etc.) creates a layer that are cached which optimizes the image building and storage process. 

Images are generally published on public or private image registries. An image built locally or in a runner as part of a CI/CD pipeline can be published and then distributed to any host that runs Docker or a container orchestration platform like Kubernetes as part of deployment. One such popular registry is Docker Hub which also publishes trusted base images.

Each image is built with a base image which is specified by the FROM instruction. Base images can be chosen based on the OS required, compatibility to technology and frameworks of the application, startup time, security requirements, storage space, reputation and updates and a host of other factors. Some popular official Docker base images include Alpine (lightweight essential Linux), Ubuntu, Python, Node, GoLang, Postgres, Redis etc.

Other instructions are used to copy files into the image (ADD & COPY), add environment variables (ENV), expose ports of the application (EXPOSE), mount volumes for persistent storage (VOLUME), set default executable (ENTRYPOINT), specify default arguments (CMD) etc. Each instruction creates a layer that is cached.

The docker CLI allows for building and testing images locally or publishing them to Docker Hub or any image registry.

### 4.4. Building the Application Image {#4.4.-building-the-application-image}

The profile web application source repository is hosted at [github.com/fareed1983/profile](http://github.com/fareed1983/profile). The application directory structure is as follows. 
``` 
├── .github  
│   └── workflows  
│       └── publish.yml  
├── .gitignore  
├── Dockerfile  
├── output  
│   ├── homepi-cicd-pipeline.html  
│   ├── images  
│   │   ├── ci-cd-raspberry-pi-terraform-kubernetes.jpg  
│   │   └── linkedin-logo.svg  
│   └── index.html  
├── README.md  
├── scripts  
│   └── convert.sh  
└── site  
    ├── homepi-cicd-pipeline.md  
    ├── images  
    │   ├── ci-cd-raspberry-pi-terraform-kubernetes.jpg  
    │   └── linkedin-logo.svg  
    └── index.md
```

The site folder contains the md files that are converted into html and outputted in the output folder when scripts/convert.sh is run. The Pandoc document converter runs from within convert.sh which also copies the images. Let’s look at the very simple Dockerfile which has instructions to build the image.

`FROM nginx:alpine`

`WORKDIR /app`

`RUN apk add --no-cache pandoc bash`

`COPY . /app`

`RUN chmod +x /app/scripts/convert.sh && /app/scripts/convert.sh`

`RUN mv /app/output/* /usr/share/nginx/html/`

`EXPOSE 80`  
`CMD ["nginx", "-g", "daemon off;"]`

[NGINX](https://nginx.org/) is an HTTP web server, reverse proxy, content cache, load balancer, TCP/UDP proxy server, and mail proxy server. We will only be using the web server part functionality of NGINX to serve our static profile web-pages. For this, we start our image with Docker Hub’s official [NGINX Alpine base image](https://hub.docker.com/_/nginx) with the FROM instruction.

We specify the WORKDIR to /app is just a scratchpad for us which is created in the image and becomes our working directory. 

We use RUN to install Pandoc but not cache it and not get stored in the layer as it will not be used at run-time and this keeps the image size small.

COPY . /app copies the entire project directory on the host into /app in the image.

Then we change the permissions of the convert.sh script to be executable and execute it. This converts all md files into html in the output folder and copies the images too. 

The output folder is then moved to a location that NGINX uses by default to serve static websites from.

We then expose port 80 so that the container can listen for HTTP connections when the users and/or orchestrators execute the container.

Finally we specify the command to execute which is nginx in our case which launches the NGINX server in the foreground.

You can now build the container locally (after installing docker) with:  
`docker build -t fareed83/profile-site:latest -f Dockerfile .`

Here ‘fareed83’ is the namespace required by Docker Hub which is my username, ‘profile-site’ is the repository name inside the namespace and ‘latest’ is the default tag name which means that this is the ‘most recent’ image of this repository.

You can list the local images locally as follows:  
`docker images`

You can run the the local image as follows:  
`docker run --rm -it -p 80:80 fareed83/profile-site:latest`

The profile website should now be served on your browser at port 80 ([http://localhost:80](http://localhost:80)). You can verify this and pat yourself on the back for your newfound knowledge.

You can remove the image:  
`docker rmi fareed83/profile-site:latest`

At this point, you should create a Docker Hub account if you don’t already have one and create a repository called profile-site. If you want to change the name, also change the name of the image you will be creating.You will need to create a personal access token to use with the CLI from ‘Account Settings’. You can now push images to your Docker Hub repository that you can keep private or publish publicly.

To push the image to Docker Hub, first login and then push as follows:  
Push image from local:  
`docker login -u "<Docker Hub username>" -p "<personal access token>"`  
`docker push <Docker Hub username>/profile-site:latest`

You can now delete the image locally and pull it again from the image repository:  
`docker pull <Docker Hub username>/profile-site:latest`

### 4.5. Application CI/CD Pipeline {#4.5.-application-ci-cd-pipeline}

We use Github Actions again to automate the building (conversion from md to HTML) and publishing (to Docker Hub) of our application image (the profile-site). This is triggered whenever we update the content on our Github repository. This image will later be picked up by a container orchestrator (K8s in our case). You will need to create two secrets in the Github repository named DOCKERHUB_USERNAME and DOCKERHUB_PASSWORD with your respective values.

Let’s look at our Github Actions workflow.

```
name: Build Website and Push Docker Image

on:  
  push:  
    branches:  
      - main

jobs:  
  build-and-push:  
    runs-on: ubuntu-latest

    steps:  
      - name: Checkout repository  
        uses: actions/checkout@v4

      - name: Set up Docker Buildx  
        uses: docker/setup-buildx-action@v3

      - name: Login to DockerHub  
        uses: docker/login-action@v3  
        with:  
          username: ${{ secrets.DOCKERHUB_USERNAME }}  
          password: ${{ secrets.DOCKERHUB_PASSWORD }}

      - name: Build and push Docker image (multi-arch)  
        uses: docker/build-push-action@v5  
        with:  
          context: .  
          file: Dockerfile  
          push: true  
          tags: fareed83/profile-site:latest  
          platforms: linux/amd64,linux/arm64
```

Steps of the workflow:

1. We are using Github’s checkout action to checkout the sources from our repository.  
2. We setup buildx which is required to generate images for multiple architectures. The default images built by Docker are for the amd64 architecture as the runner is x86_64. The Raspberry Pi 5 is an arm64/armv7 platform. Thus we will build for both amd64 and arm64 architectures. Buildx uses QEMU under the hood to build for multiple architectures. We can use buildx on the command-line too for [multi-platform builds](https://docs.docker.com/build/building/multi-platform/). Instead of `docker build` we can use `docker buildx build -t fareed83/profile-site:latest -f Dockerfile --platform linux/amd64,linux/arm64 .` But here our purpose is CI/CD automation.  
3. We then login to Docker Hub with secrets that we stored in our Github repository.  
4. Finally we use the build-push-action to build the image the steps of which are specified in the Docker file and then push the built images of both platforms to Dockerhub.

We are now ready to let the orchestration begin!


## 5\. Kubernetes {#5.-kubernetes}

We can manage a few docker containers easily running applications on servers. However, when hundreds of containers are to be managed throughout their lifecycle, things can get very complicated without the use of automation. As per [RedHat](https://www.redhat.com/en/topics/containers/what-is-container-orchestration), “Container orchestration is the process of automating the deployment, management, scaling and networking of containers throughout their lifecycle, making it possible to deploy software consistently across many different environments at scale”.

### 5.1. Introduction to Kubernetes {#5.1.-introduction-to-kubernetes}

The most common container orchestration platform is [Kuberenetes](https://kubernetes.io/docs/concepts/overview/#why-you-need-kubernetes-and-what-can-it-do) (K8s) which is used in self-hosted servers and also supported by various cloud providers natively. Features include service discovery, load balancing, storage management, automated rollouts, rollbacks, container sizing, secret management, configuration management, scaling etc.

K8s comprises a set of independent composable control processes that continuously drive the current state of infrastructure towards a desired state. K8s is deployed as a cluster of a controller plaine plus a set of worker nodes that run containerised applications. In the Raspberry Pi, we will be using K3s which is a bare minimal K8s distribution that can bundle the control plane and worker node into a single-node cluster. The K8s control plane hosts an API server that is exposed to users and other parts of the cluster. K8s provides a kubectl CLI that enables interaction and management of clusters.

K8s resources are described in YAML files which are executed with `kubectl apply -f config-file.yaml` which would then create and/or update components as per the configuration supplied. Files contain metadata  that contains labels and specification that contains selectors.

### 5.2. Basic Kubernetes Concepts {#5.2.-basic-kubernetes-concepts}

**Node**  
These are machines, physical or virtual, that are interconnected and coordinated as part of a K8s cluster. They can either be the control plane or workers that contain the pods. Use the command `kubectl get nodes` to list all the nodes on a cluster.

**Namespaces**  
They provide a means of isolating groups of resources within a single cluster and provide a scope for names. Names of resources must be unique within a namespace. Use the command `kubectl get namespaces` to list all the namespaces of a cluster.

**Pods**  
The smallest deployable units of computing in K8s comprising of one or more containers that can be created and managed in Kubernetes. Pods are processes. Generally, pods have single containers. However when multiple containers are run in the same pod, they share resources like the same network namespace and storage volumes. Generally auxiliary containers are bundled to a main application in a pod for which logging and monitoring are good examples of. Each pod in a cluster gets its own unique cluster-wide IP address. Processes running in different containers in the same pod can communicate with each other over localhost.  Use the command kubectl `get pods -n <namespace>` to list all the pods in a namespace.

**Services**  
They are a logical set of pods and a policy by which to access them. They provide a stable and consistent IP address and DNS name even if pods containing an application are added or removed. Services can be used to distribute network traffic across multiple pods for load balancing. A service can be exposed to the public internet using an ingress or a gateway. There are several service types:

* ClusterIP - Exposes the service through an internal IP accessible only by other cluster resources. A good use-case would be a database or internal API calls to an internal micro-service.  
* NodePort - Exposes the service at a static port which is accessible externally using <nodeIP>:<nodePort>. The control plane will allocate a port from a range or you can specify it. It is used to set up your own load balancing solution, to configure environments not fully supported by K8s or even to expose one or more nodes’ IP addresses directly.  
* LoadBalancer - The service is accessible through the cloud provider’s load balancer (like AWS ALB). Here, K8s does not directly provide a load balancing component.  
* ExternalName - Maps the service to a DNS name outside the cluster. When looking up the host with local DNS, the DNS service returns a CNAME record with the value of the external domain name.

**Deployments**  
A deployment manages a replicated set (ReplicaSet) of pods to run an application workload, usually stateless. Deployments help to scale replica pods, enable rollout or rollbacks across replica pods.

**StatefulSets**  
Deployments manage stateless applications while StatefulSets manage applications that require persistent storage, like database instances. Keep in mind that the general practice is to host clustered databases outside the K8s cluster.

**Volumes**  
Allows pods that require data persistence to access and share data persistently via the filesystem. Data stored in volumes persists across container restarts. Volumes are mounted at specified paths within the container file system. 

**PersistantVolumes**  
PVs are cluster resources that have a lifecycle independent from any individual pod that uses the PV. A PV has to be requested by pods through a PersistentVolumeClaim (PVC). A PVC should be in the same namespace as the pod claiming it.

**Ingress**  
[Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) allows making HTTP/s services available using a protocol-aware configuration mechanism that understands concepts like URIs, hostnames, paths etc. Ingress is a level-7 proxy server or load balancer that routes HTTP/s requests to services. It can funnel multiple virtual hosts and paths through one external address and then routes them services internally. It also terminates TLS such that pods only need to handle HTTP requests without encryption. Other optional utilities are rate limiting, firewall, authentication etc. There are ingress controllers available for Apache, Traefik, nginx, AWS etc. We will be using the nginx ingress controller because it is widely used, lightweight, mature and performant. 

**CRDs**  
Custom Resource Definitions (CRD) allows extension of the K8s API by defining custom resource types. It is a YAML object that extends the K8s API allowing for the management of new types of objects beyond the defaults like pods and services. After registration of custom resources, instances of the new type of resource can be created, read, updated and deleted.

**ConfigMap**  
Are consumed by pods as environment variables, command-line arguments or configuration files and are stored as key-value pairs. They allow decoupling of environment-specific configuration from container images.

**Secrets**  
Are similar to ConfigMaps but are used to store sensitive values like password, tokens, keys etc. 

**Helm**  
[Helm](https://helm.sh/) is a templating engine that acts as a package manager for Kubernetes allowing for easier configuration of a common set of resources for a given use-case. There are standard bundles published in public or private repositories which act as reusable recipes for infrastructure deployment eliminating the need of configuring complex but widely used deployment patterns from scratch. Helm uses charts to describe how to run individual applications and services on Kubernetes. Without Helm, Kubernetes YAML files contain hard-coded configuration values for such resources as ports, number of replicas etc. Also, for each application, multiple YAML files have to be updated without Helm. Helm introduces a templating system that takes values from a YAML file that it applies to charts.

### 5.3. Installation of k3s Cluster {#5.3.-installation-of-k3s-cluster}

K3s is a CNCF-conformant Kubernetes distribution which means that it implements the specified APIs that are standardized to manage a cluster. Install K3s in the setup\_pi.yml Ansible playbook as follows. Note that the default ingress controller in K3s is Traefik which we intend to replace with NGNIX. Add the following to the Ansible playbook before the handlers section.
```
   - name: Enable cgroup memory in cmdline.txt
      lineinfile:
        path: /boot/firmware/cmdline.txt
        # This regex captures the entire line as group 1
        # The 'line' puts cgroup_memory=1 cgroup_enable=memory at the end of that line
        regexp: '^(.*)$'
        line: '\1 cgroup_memory=1 cgroup_enable=memory'
        backrefs: yes
      when: "'cgroup_memory=1 cgroup_enable=memory' not in cmdline_content.stdout"

    - name: Check if K3s is installed
      stat:
        path: /usr/local/bin/k3s
      register: k3s_bin

    - name: Install K3s
      shell: curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik  --tls-san {{ pi_host }}" sh -
      # We disable trafik as the default ingress controller
      when: not k3s_bin.stat.exists

    - name: Fetch K3s kubeconfig from Pi
      fetch:
        src: /etc/rancher/k3s/k3s.yaml
        dest: ../../terraform/k3s.yaml
        flat: yes
      become: yes
```

In the above,

1. We ensure that the kernel command line enables memory cgroup support required for K3s to manage container resources. Standard Raspberry Pi OS installations do not start with cgroups enabled that are required to start the systemd service. We use the lineinfile Ansible module to append the required parameters when they are not present.  
2. Then we check if K3s is installed by looking for the existence of the K3s binary else we install K3s with a shell command and disable Traefik which is the default ingress controller.
3. We then fetch the k3s.yaml file which is used to enable remote management of the K8s cluster using the K8s API.

The data in the k3s.yaml should be kept secret and not shared. We will pull this file into the runner and replace the IP address with the domain name of our Raspberry Pi. Also, we will have to allow the port 6443 in UFW and also forward the port from our router. Communication on this port will be secure because it uses a client-certificate and the client-key-data which is a private key to authenticate the user who can act as the administrator of the cluster. The certificate-authority-data will be used to verify the server and encrypt data in transit with TLS.

We also add the below to the GitHub Actions workflow:

```
     - name: Update server IP in kubeconfig and set path
        run: |
          sed -i "s|127.0.0.1|$PI_HOST|g" ./terraform/k3s.yaml
          echo "KUBE_CONFIG_PATH=$(pwd)/terraform/k3s.yaml" >> $GITHUB_ENV
```

We do this to change the localhost IP to the provided PI host. Also we set the environment variable required to reference the right K3s configuration for remote management.

After the GitHub Actions workflow is run on merge to the main branch, use sudo `kubectl get pods -n kube-system` on the Raspberry Pi to get an output like the below:  
      
`NAME                                      READY   STATUS    RESTARTS   AGE`  
`coredns-ccb96694c-cbzzt                   1/1     Running   0          110s`  
`local-path-provisioner-5cf85fd84d-mgmtr   1/1     Running   0          110s`  
`metrics-server-5985cbc9d7-pkh2d           1/1     Running   0          110s`

The first part of the command, “kubectl get pods” gets all pods running on the Kubernetes cluster. As no services are deployed, it will not return anything. Adding “-n kube-system” allows the listing of pods running in the kube-system namespace which are core system services. A pod can have multiple containers. The second row, “READY” means that 1 pod out of 1 in the container is running correctly. The other columns are self-explanatory.

### 5.4. Manual Configuration of Web Application Pods {#5.4.-manual-configuration-of-web-application-pods}

To get somewhat of a better grasp on how things really work under the hood, we can host the website using K3s installed on the Raspberry PI by using manual commands on the CLI to better understand the deployment automated by Terraform. We leave it as an exercise to the reader to manually configure the web application using the kubectl command-line based on the automated Terraform IaC pipeline described below.

### 5.5. High-Level Architecture of Workload {#5.5.-high-level-architecture-of-workload}

Our infrastructure application stack will consist of the following resources:

| Layer | Component/Resource (Kind, Name, Namespace) | Purpose |
| :---- | :---- | :---- |
| Edge and TLS | NGINX Ingress Controller (installed with Helm) helm_release.nginx_ingress, ns ingress-nginx | Cluster-wide L7 proxy terminating TLS & routing HTTP to services |
|  | Service created by the chart (LoadBalancer) | Exposes ingress controller on a public IP |
|  | Ingress (profile-site-ingress, ns default) | Declares host-based and path-based rules and forces HTTPs |
| Certificate Management | [cert-manager](http://cert-manager.io/docs/) (installed with Helm) Helm_release.cert_manager, ns cert-manager | CRDs and controllers to issue and renew X.509 certificates for TLS |
|  | Clusterissuer letsencrypt-prod, cluster-scoped | Configuration for Let’s Encrypt that is referenced by ingress |
|  | Certificate Profile-site-tls, ns default | cert-manager automatically requests it and stores key+cert in a secret |
| Application Workload | Deployment Profile-site, ns default | Manages the profile-site pod/s and keeps them running |
|  | Pod template Inside Deployment | Container running fareed83/profile:latest image and mounts an volume for Nginx cache |
|  | ReplicaSet / Pods Managed by Deployment | We have only one running replica created during rollouts |
| Networking inside cluster | Service Profile-site-service, ClusterIP | Ingress forwards requests to this IP address and used for load-balancing |
| Storage (ephemeral) | Volume emptyDir called nginx-cache | /var/cache/nginx is mounted in container |

## 6\. Terraform {#6.-terraform}

You will realize that the K8s architecture required to run a fairly complex application stack can get unwieldy if manually configured on scale. Thus, we will automate our K8s infrastructure deployment using Terraform.

### 6.1. Terraform Introduction {#6.1.-terraform-introduction}

Terraform is an infrastructure-as-a-code tool created by HashiCorp which allows the definition of data center infrastructure in a human readable declarative configuration language known as HCL. With terraform, consistent workflow can be used to provision and manage infrastructure throughout its lifecycle. You can apply the same config multiple times and get the same result and manage infrastructure changes via Git. Terraform makes infrastructure deployments predictable, auditable and automated.

Terraform creates and manages resources on cloud platforms and other services through their application programming interfaces. For example, it uses the K8s API to manage a K8s compliant cluster and the K8s resources can be declared in HCL like we will be doing in the final part of our project.

### 6.2. Basic Terraform Concepts {#6.2.-basic-terraform-concepts}

**Providers**  
Are plugins distributed separately from Terraform that provide capabilities to interface with APIs of cloud platforms or services. Some popular ones are providers for [AWS](https://library.tf/providers/hashicorp/aws/latest), [GCP](https://library.tf/providers/hashicorp/aws/latest), [Azure](https://library.tf/providers/hashicorp/azurerm/latest) and ones we will be using - [Kubernetes](https://library.tf/providers/hashicorp/kubernetes/latest) and [Helm](https://library.tf/providers/hashicorp/helm/latest). There are also providers for utilities like [random number generation](https://library.tf/providers/hashicorp/random/latest), [file archive management](https://registry.terraform.io/providers/hashicorp/archive/latest/docs), [time management](https://registry.terraform.io/providers/hashicorp/time/latest/docs) etc. For browsing through the list of official providers and their documentation, visit the [Terraform Registry](https://registry.terraform.io/). Providers are declared in the required_providers block and installed when `terraform init` is run. Each resource type is implemented by a provider.

**Resources**  
Defined in resource blocks in the Terraform configuration, they are infrastructure objects representing virtual networks, compute instances of higher-level components like DNS records. A resource block declares a resource of a specific type and a specific local name which can be used to refer to the resource in the same module. A resource type specifies the type of infrastructure object it manages and the arguments and attributes the resource supports. To understand resources of a particular provider, refer to the Terraform Registry. When resource blocks are modified HCL files and `terraform plan` is run, Terraform will first calculate the differences in the current state to the desired state in the HCL files and apply the changes at the next `terraform apply`. For example, if a resource block is added, Terraform will provision the resource in the infrastructure and if a block is deleted, the corresponding provisioned resource will be deleted.

**Data Sources**  
Allow Terraform to use information defined outside of Terraform by another separate Terraform configuration, or modified by functions. They are read-only views to fetch or query things that already exist or are managed outside Terraform. In our first example, we use the Kubernetes Namespace to retrieve the UUID of the K8s cluster we installed and output it as a variable.

**Modules**  
Containers for multiple resources that are used together to fulfill a purpose like setting up a K8s cluster. A collection of .tf files make up a module and are kept together in a directory. Modules help organize reuse of Terraform code.

**State**  
Used to keep track of the current state of resources in the real-world to understand which changes are required to match the current state of deployed infrastructure with the desired state as per configuration files. It is recommended to store state in a remote shared backend and not in individual workstations to avoid drift and conflicts in between teams. We use Terraform.io to save the state file.

**Variable**  
Terraform has input and output variables. Input variables serve as parameters for a Terraform module which allows customizing behaviour. Output variables return values for a Terraform module.

### 6.3. Terraform Creation of Workload {#6.3.-terraform-creation-of-workload}

Providers we will be using and the resources they will create are as follows:

1. [hashicorp/helm](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) - Used to deploy software packages in K8s as described earlier. We will invoke Helm to install packages software (charts) inside the cluster. These are installed as K8s cluster add-ons. We deploy the following package resources using Helm:  
   1. [helm_release.ngnix_ingress](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx) - This creates a deployment, service, ConfigMap etc required to deploy the ingress controller, the NGINX reverse proxy that watches Ingress objects and routes external traffic into the cluster. It is exposed by the K3s LoadBalancer.  
   2. [helm_release.cert_manager](https://cert-manager.io/docs/installation/helm/) - This uses the jetstak/cert-manager chart to crate deployments, webhooks and CRDs to install cert-manager which requests and renews TLS certificates by observing annotations on ingress or certificate resources.  Also CRDs required.  
2. [hashicorp/kubernetes](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) - Used to interact with resources supported by K8s. As part of our GitHub CI/CD pipeline we saved the k3s.yaml file which are credentials used to interact with our K8s cluster. When we apply changes as per our configuration file, these credentials are used to interact with the K8s API hosted by our cluster. From this provider, we deploy the following resources:  
   1. [kubernetes_deployment.web_app](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) - It creates a K8s deployment in the default namespace that launches a single replica of the fareed83/profile-site image, with an emptyDir cache volume and strict pod security. As described earlier, deployments keep pods available and support roll-outs and rollbacks.  
   2. [kubernetes_service.webservice](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) - It creates a K8s service of type ClusterIP that provides a stable virtual IP that load-balances traffic to pods. The ingress targets this service.  
   3. [kubernetes_ingress_v1.web_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/2.19.0/docs/resources/ingress_v1) - Creates a single K8s ingress object that contains hostname, path rules and TLS settings that tells the controller installed by nginx_ingress how to route the profile website (fareed.digital) to profile-site-service and request a certificate from certificate-manager. It acts as the routing rule book.  
3. [gavinbunney/kubectl](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs) - This applies the clusterIssuer.yaml which contains the Let’s Encrypt configuration and is needed before the web ingress requests a certificate.  
4. [hashicorp/time](https://registry.terraform.io/providers/hashicorp/time/latest/docs) - Used to sleep and ensure that CRDs are installed by Helm before the ClusterIssuer tries to issue a TLS certificate.

### 6.4. Terraform Bootstrapping {#6.4.-terraform-bootstrapping}

The following changes are required in the GitHub Actions workflow to execute the Terraform automation after the Ansible Playbook is run. We install Terraform and then init, plan and apply the configuration to our K8s cluster. Add the following to the GitHub Actions workflow under where we edit the k3s.config file. 

     - name: Install Terraform  
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init  
        working-directory: ./terraform  
        run: terraform init

      - name: Terraform Plan  
        working-directory: ./terraform  
        run: terraform plan  
        
      - name: Terraform Apply  
        working-directory: ./terraform  
        run: terraform apply -auto-approve

For storing the state of our Terraform pipeline, we will use Terraform Cloud. Create an account on Terraform Cloud and make a new organization and create a project in the organization. Create a new CLI-driven workflow as we are using GitHub Actions to fully run our CI/CD pipeline. We will be running terraform init/plan/apply from GitHub Actions rather than from Terraform Cloud.

Add the following to terraform/providers.tf to initialize the state store and providers.

```
terraform {  
  cloud {  
    hostname     = "app.terraform.io"  
    organization = "<name of the organization created in terraform.io>"

    workspaces {  
      name = "<name of the workspace created in terraform.io>"  
    }  
  }

  required_providers {  
    kubernetes = {  
      source  = "hashicorp/kubernetes"  
      version = "~> 2.35"

    }  
    helm = {  
      source  = "hashicorp/helm"  
      version = "~> 2.17"  
    }

    kubectl = {  
      source  = "gavinbunney/kubectl"  
      version = ">= 1.19.0"  
    }

    time = {  
      source  = "hashicorp/time"  
      version = "~> 0.9"  
    }

  }  
}
```

Add the required_providers section above to declare which providers your configuration depends upon and their download locations along with the version numbers that need to be enforced. When you run `terraform init` these providers will be downloaded and installed from the Terraform Registry.

Go to Terraform Cloud settings and generate a Terraform team token. Do not commit this token in your code. Instead, store the token as a GitHub Actions secret named TERRAFORM_CLOUD_TOKEN. We will reference this token in our GitHub actions workflow YAML to insert it into the runner for Terraform to use as an environment variable called TF_TOKEN_app_terraform_io when initializing. 

Add to env section of the Ansible Playbook: `TF_TOKEN_app_terraform_io: ${{ secrets.TERRAFORM_CLOUD_TOKEN }}`

### 6.5. Basic Terraform Test {#6.5.-basic-terraform-test}

Create a file called test_connection.tf with the following contents
:
```
# 1) Tell Terraform how to find your K3s kubeconfig  
#    Adjust the path to wherever you placed k3s.yaml after Ansible fetch.  
provider "kubernetes" {  
  config_path = "${path.module}/k3s.yaml"  
}

# 2) Use a data source to read the "kube-system" namespace  
data "kubernetes_namespace" "kube_system" {  
  metadata {  
    name = "kube-system"  
  }  
}

# 3) Output the namespace UID so we can confirm Terraform actually read it.  
output "kube_system_uid" {  
  value       = data.kubernetes_namespace.kube_system.metadata.0.uid  
  description = "Unique ID of the kube-system namespace."  
}
```

**Run Terraform From Local Machine**

To run Terraform from the local machine, first export the following variables:  
```
export PI_SSH_PORT=”<Your Pi SSH port>”  
export PI_HOST="<Your Pi Hostname>"  
export PI_USER="<Your Pi Username>"  
export TF_TOKEN_app_terraform_io="<Your Terraform Token>"  
export KUBE_CONFIG_PATH=./k3s.yaml
```

Then run:

`terraform init`

`terraform plan`

`terraform apply`

Test out configuration so far locally. You should see the executed plan on Terraform Cloud. After this pipeline is applied successfully, Terraform Cloud will reflect the output and you can verify if the kube_system_uid is proper from Terraform Cloud running the below command:  
`kubectl get namespace kube-system -o json`

**Run Terraform With GitHub Actions**

Since you have added the above commands to the GitHub Actions pipeline, they will be executed when you push your code to your GitHub repository.

### 6.6. Completed IaC Pipeline {#6.6.-completed-iac-pipeline}

Create a file called profile.tf and add the following:
```
variable "domain" {  
  type    = string  
  default = "fareed.digital"  
}

variable "profile_app_image" {  
  type    = string  
  default = "fareed83/profile-site:latest"  
}

# Deploy NGINX Ingress Controller  
resource "helm_release" "nginx_ingress" {  
  name             = "nginx-ingress"  
  repository       = "https://kubernetes.github.io/ingress-nginx"  
  chart            = "ingress-nginx"  
  namespace        = "ingress-nginx"  
  create_namespace = true

  set {  
    name  = "controller.service.type"  
    value = "LoadBalancer"  
  }

  set {  
    name  = "controller.ingressClassResource.default"  
    value = "true"  
  }  
}

resource "helm_release" "cert_manager" {  
  name             = "cert-manager"  
  repository       = "https://charts.jetstack.io"  
  chart            = "cert-manager"  
  namespace        = "cert-manager"  
  create_namespace = true  
  version          = "v1.17.2"

  set {  
    name  = "installCRDs"  
    value = "true"  
  }  
}

resource "time_sleep" "wait_for_cert_manager_crds" {  
  depends_on      = [helm_release.cert_manager]  
  create_duration = "30s"  
}

locals {  
  clusterissuer = "clusterissuer.yaml"  
}

# Create clusterissuer for nginx YAML file  
data "kubectl_file_documents" "clusterissuer" {  
  content = file(local.clusterissuer)  
}

resource "kubectl_manifest" "clusterissuer" {  
  for_each  = data.kubectl_file_documents.clusterissuer.manifests  
  yaml_body = each.value  
  depends_on = [  
    data.kubectl_file_documents.clusterissuer,  
    time_sleep.wait_for_cert_manager_crds // Wait until CRDs are established  
  ]  
}

# Deploy the Web App (simplified, without read_only_root_filesystem)  
resource "kubernetes_deployment" "web_app" {  
  metadata {  
    name      = "profile-site"  
    namespace = "default"  
    labels = {  
      app = "profile-site"  
    }  
  }

  spec {  
    replicas = 1

    selector {  
      match_labels = {  
        app = "profile-site"  
      }  
    }

    template {  
      metadata {  
        labels = {  
          app = "profile-site"  
        }  
      }

      spec {  
        # Declare the volume (emptyDir is writable by default)  
        volume {  
          name      = "nginx-cache"  
          empty_dir {}  
        }

        # Set pod-level security with fsGroup so volumes are group-owned by 101.  
        security_context {  
          fs_group = 101  
        }

        container {  
          name  = "profile-site"  
          image = var.profile_app_image  
          image_pull_policy = "Always"

          # Mount the volume where Nginx can write caches/temp files.  
          volume_mount {  
            name       = "nginx-cache"  
            mount_path = "/var/cache/nginx"  
          }

          port {  
            container_port = 80  
          }

          resources {  
            requests = {  
              cpu    = "100m"  
              memory = "256Mi"  
            }  
            limits = {  
              cpu    = "200m"  
              memory = "256Mi"  
            }  
          }

          security_context {  
            allow_privilege_escalation = false  
            # Note: Removing read_only_root_filesystem ensures the container filesystem is writable.  
            # Instead of making the entire filesystem read-only, we allow writes so that chown operations can succeed.  
            capabilities {  
              drop = ["ALL"]  
              add  = ["CHOWN", "SETGID", "SETUID"]  
            }  

          }

          liveness_probe {  
            http_get {  
              path = "/"  
              port = 80  
            }  
            initial_delay_seconds = 5  
            period_seconds        = 10  
          }  
        }  
      }  
    }  
  }  
}

# Create a Service for the Web App  
resource "kubernetes_service" "web_service" {  
  metadata {  
    name      = "profile-site-service"  
    namespace = "default"  
  }

  spec {  
    selector = {  
      app = kubernetes_deployment.web_app.metadata[0].labels.app  
    }

    port {  
      protocol    = "TCP"  
      port        = 80  
      target_port = 80  
    }

    type = "ClusterIP"  
  }  
}

# Ingress Resource for HTTPS with Redirect  
resource "kubernetes_ingress_v1" "web_ingress" {  
  depends_on = [  
    helm_release.nginx_ingress,  
    helm_release.cert_manager,  
    # kubernetes_manifest.letsencrypt_issuer  
    kubectl_manifest.clusterissuer  
  ]

  metadata {  
    name      = "profile-site-ingress"  
    namespace = "default"  
    annotations = {  
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"  
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"  
    }  
  }

  spec {  
    rule {  
      host = var.domain  
      http {  
        path {  
          path      = "/"  
          path_type = "Prefix"  
          backend {  
            service {  
              name = kubernetes_service.web_service.metadata[0].name  
              port {  
                number = 80  
              }  
            }  
          }  
        }  
      }  
    }

    tls {  
      secret_name = "profile-site-tls"  
      hosts       = [var.domain]  
    }  
  }  
}
```

Following is the explanation of the above Terraform configuration:

1. Helm installs controllers  
   1. Ingress-NGINX is installed, exposing a LoadBalancer service  
   2. cert-manager deploys webhooks and registers CRDs  
2. Sleep 30s to make sure CRDs are ready before proceeding  
3. ClusterIssuer is applied and cert-manager can now issue certificates using Let’s Encrypt  
4. App deployment and the service which creates the running pods and an endpoint that is internal to the cluster.  
5. Ingress is then configured which does the following:  
   1. NGINX controller detects the new ingress, configures a virtual host for fareed.digital and proxies traffic to profile-site-service.  
   2. cert-manager’s ingress-shim detects the cert-manager.io/cluster-issuer annotation, performs the ACME HTTP-01 challenge through NGINX, and stores the resulting certificate in profile-site-tls.  
   3. On certificate renewal, the same flow repeats automatically.  
6. Terraform state records every object so the next plan will only show the drift or changes required to match the desired state.

## 7\. Final Thoughts {#7.-final-thoughts}

That was quite a handful\! I hope this helped you understand the complexity and nuances of modern CI/CD and IaC workflows. I will continue to update this article as I get more insights and clarity on how the setup operates and evolve this already-endless article. So, check back again.

# [< Back to Fareed R](./index.md)
