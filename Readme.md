# Deploy Azure VM Using Terraform & GitHub Actions with OIDC

This project shows how to deploy a basic virtual machine on Microsoft Azure using Terraform, and automate the deployment with GitHub Actions. The workflow uses OpenID Connect (OIDC) to securely authenticate to Azure—without storing secrets in your code or GitHub.

---

## 🔧 What This Project Does
- Provisions an Azure virtual machine with a network setup
- Uses GitHub Actions to run Terraform (`init`, `plan`, `apply`, `destroy`)
- Authenticates to Azure using GitHub OIDC (no service principal secrets required)
- Demonstrates how to securely manage credentials and automate infrastructure

---

## ✅ What You Need Before You Start
- Azure subscription
- A GitHub repository (this repo or your own fork)
- Azure CLI installed (only for the initial setup)

---

## ⚙️ One-Time Setup on Azure

### Step 1: Create a Service Principal
Run the following in your terminal:
```bash
az login
az ad sp create --name "terraform-gh-action" --role contributor \
  --scopes "/subscriptions/<YOUR_SUBSCRIPTION_ID>"
```
Save the following values:
- `appId` → used as `AZURE_CLIENT_ID`
- `tenant` → used as `AZURE_TENANT_ID`
- Your subscription ID → used as `AZURE_SUBSCRIPTION_ID`

---

### Step 2: Link GitHub to Azure with Federated Identity
1. Go to **Azure Portal > Azure Active Directory > App Registrations**
2. Select the service principal you just created
3. Open **Federated credentials** → click **Add credential**
4. Fill the fields:
   - **Name**: `terraform-gh-main`
   - **Entity Type**: `Repository`
   - **Entity Name**: `your-org/your-repo`
   - **Subject**: `repo:your-org/your-repo:ref:refs/heads/main`
   - **Issuer**: `https://token.actions.githubusercontent.com`
   - **Audience**: `api://AzureADTokenExchange`

---

### Step 3: Add Secrets to Your GitHub Repo
In GitHub → Settings → Secrets → Actions → New repository secret:

| Name                      | Value                          |
|---------------------------|---------------------------------|
| `AZURE_CLIENT_ID`         | Your appId                     |
| `AZURE_TENANT_ID`         | Your tenant ID                 |
| `AZURE_SUBSCRIPTION_ID`   | Your Azure subscription ID     |
| `TF_VAR_admin_username`   | e.g. `azureuser`               |
| `TF_VAR_ssh_public_key`   | Your SSH public key            |
| `TF_VAR_vnet_address_space` | e.g. `["10.0.0.0/16"]`       |
| `TF_VAR_subnet_prefix`      | e.g. `["10.0.2.0/24"]`       |

---

## 📁 Terraform Setup

### `provider.tf`
```hcl
provider "azurerm" {
  features {}
}
```
> No credentials are hardcoded. Everything is passed through environment variables.

### Backend (Optional)
If using remote state storage:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "example-rg"
    storage_account_name = "examplestorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.112.0"
    }
  }
}
```
> Your service principal must have access to these backend resources.

---

## 🧪 GitHub Actions Workflow

### Why We Pass `ARM_` Environment Variables
Each step in GitHub Actions runs in a new shell. If you don’t pass the `ARM_*` environment variables in every Terraform step, Terraform falls back to Azure CLI, which doesn’t work with OIDC.

### Example Environment Block
```yaml
env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_USE_OIDC: true
```

### Example Workflow Steps

#### Terraform Init
```yaml
- name: Terraform Init
  run: terraform init
  env: *arm_env
```

#### Terraform Plan
```yaml
- name: Terraform Plan
  run: terraform plan
  env: *arm_env
```

#### Terraform Apply
```yaml
- name: Terraform Apply
  run: terraform apply -auto-approve
  env: *arm_env
```

#### Terraform Destroy
```yaml
- name: Terraform Destroy
  run: terraform destroy -auto-approve
  env: *arm_env
```

> Tip: You can use YAML anchors like `*arm_env` to avoid repeating the same environment block if you want.

---

## 🧪 Running Terraform Locally (Optional)
```bash
export TF_VAR_admin_username="azureuser"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
terraform init
terraform plan
terraform apply
```

---

## 🔄 Terraform Outputs
After successful deployment, you can output details like:
- VM name and IP
- Resource group name
- NIC or subnet ID

Add these in your `outputs.tf` file as needed.

---

## ✅ Recap Checklist
| Task                                        | Done? |
|---------------------------------------------|--------|
| OIDC login set up with federated identity   | ✅     |
| GitHub secrets securely configured          | ✅     |
| Terraform workflow fully automated          | ✅     |
| SSH key used for VM access                  | ✅     |
| No sensitive credentials exposed            | ✅     |

---

## 👨‍💻 Notes
This setup helps you manage infrastructure with confidence. OIDC keeps your secrets secure, GitHub Actions automates your deployments, and Terraform ensures your Azure resources are consistent.

You can extend this project with storage accounts, databases, or convert it into a module or template as needed.
-

## 👤 Author
Saket Kumar Vishwakarma  
System Engineer at TCS  
DevOps | Cloud | Automation Enthusiast