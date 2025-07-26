# Azure VM Deployment with Terraform & GitHub Actions

This project shows how to deploy a simple Virtual Machine in Microsoft Azure using Terraform. The deployment is automated using GitHub Actions, and all sensitive information like credentials and SSH keys are managed securely.

---

## 📁 Project Overview

This repository contains everything needed to:
- Provision an Azure Virtual Machine
- Use GitHub Actions for CI/CD
- Follow Terraform best practices (e.g., remote secrets, clean structure)
- Avoid committing any sensitive files or credentials

---

## 🔐 Security First

- Secrets like SSH keys and service principal credentials are stored securely in **GitHub Secrets**
- `terraform.tfvars` is excluded using `.gitignore`
- All sensitive variables (passwords, keys) are marked `sensitive = true`
- SSH is used to access the VM — password login is disabled

---

## 🧰 Prerequisites

Make sure you have:
- An Azure subscription
- A GitHub account with access to create secrets
- Terraform installed (only for local testing)

---

## ☁️ Azure Setup

### Step 1: Create a Service Principal
Use the Azure CLI to create a service principal that Terraform can use:

```bash
az login
az ad sp create-for-rbac --name "yourusername" --role="Contributor" \
  --scopes="/subscriptions/<your-subscription-id>" --sdk-auth
```

Copy the entire JSON output and save it as a GitHub Secret named:
```
AZURE_CREDENTIALS
```

---

### Step 2: Generate an SSH Key
If you don’t already have an SSH key:

```bash
ssh-keygen -t rsa -b 4096 -C "azureuser@vm"
```

This creates:
- A private key: `~/.ssh/id_rsa`
- A public key: `~/.ssh/id_rsa.pub`

Add the public key content as a GitHub secret:
- `TF_VAR_ssh_public_key`

Also set:
- `TF_VAR_admin_username` → usually `azureuser`
- `TF_VAR_vnet_address_space` → e.g., `["10.0.0.0/18"]`
- `TF_VAR_subnet_prefix` → e.g., `["10.0.2.0/28"]`

---

## ⚙️ GitHub Actions Workflow Explained

The workflow is defined in `.github/workflows/terraform.yml`. It’s designed to be manually triggered and supports both deployment and teardown.

### What It Does:
- Checks out the code
- Logs into Azure using your GitHub secret
- Sets up Terraform v1.6.6
- Runs `terraform init`, `fmt`, and `validate`
- Executes a plan to show what will change
- Based on input, either **applies** or **destroys** the infrastructure

You can trigger this from the GitHub Actions tab with a single click.

---

## 🚀 Running Locally (Optional)

You can test locally using the CLI:
```bash
export TF_VAR_admin_username="azureuser"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
terraform init
terraform plan
terraform apply
```

Do **not** commit your `.tfvars` file or any key material.

---

## 📦 Outputs
After deployment, Terraform prints useful info like:
- Resource group name
- Private IP address of the VM
- VM and NIC resource IDs

---

## ✅ Summary

| What Was Done                      | Done? |
|-----------------------------------|-------|
| Secure credential storage         | ✅     |
| GitHub Actions automation         | ✅     |
| No hardcoded secrets or passwords | ✅     |
| SSH-only VM login                 | ✅     |
| Clean and modular setup           | ✅     |

---

## 👤 Author
Saket Kumar Vishwakarma  
System Engineer at TCS  
DevOps | Cloud | Automation Enthusiast

---

Let me know if you want help adding storage, databases, or making this a reusable module for other teams.
