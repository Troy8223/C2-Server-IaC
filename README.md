# C2-Server-IaC

This project provides Infrastructure as Code (IaC) for deploying a Command and Control (C2) server environment on AWS using Terraform and Ansible. It automates the provisioning of AWS resources, IAM roles, S3 buckets, and the configuration of EC2 instances as team servers and redirectors, including secure HTTPS setup with Let's Encrypt.

# Architecure

The infrastructure consist of,
1. two HTTP/HTTPS redirectors
2. one CobaltStrike teamserver

## Features

- **Terraform** for AWS infrastructure provisioning:
  - Security Groups, EC2 instances (teamserver and redirectors)
  - IAM roles and policies for S3 access

- **Ansible** for configuration management:
  - Automated setup of teamserver and redirector roles
  - Nginx reverse proxy configuration for redirectors
  - Automated SSL certificate provisioning with Let's Encrypt (Certbot)
  - Secure firewall (UFW) configuration


## Getting Started

To get started, clone the repository and navigate to the project directory:

```bash
git clone https://github.com/yourusername/C2-Server-IaC.git
cd C2-Server-IaC
```

### Prerequisites

- Terraform
- Ansible
- AWS CLI
- Python 3.x
- Pip

### Installation

1. Install the required Terraform providers and modules:

   ```bash
   cd terraform
   terraform init
   ```

2. Configure your AWS credentials:

   ```bash
   aws configure
   ```

3. Check deplyment of the infrastructure using Terraform:

   ```bash
   terraform plan
   ```

4. Deploy the infrastructure using Terraform:

   ```bash
   terraform apply
   ```

5. Modify neccessary information about the resources in inventory.yaml

    e.g. domain name of the redirectors, public ip address of resources and ssh key files location etc.

6. Configure the servers using Ansible:

   ```bash
   cd ansible
   ansible-playbook -i inventory.yaml c2_setup.yaml
   ```

## Usage

After the deployment is complete, you can access your C2 server environment using the domain names and IPs. The team servers and redirectors will be automatically configured and secured with Let's Encrypt SSL certificates.
