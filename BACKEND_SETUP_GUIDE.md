# Terraform Backend Setup Guide

Complete guide for application teams to set up Azure Storage backend for Terraform state management.

---

## Overview

Terraform state files must **never be committed to version control**. This guide shows you how to store state securely in Azure Storage, where it's encrypted and versioned.

**Time Required:** 15-20 minutes

---

## Prerequisites

- ✅ Azure CLI installed: `az --version`
- ✅ Logged in to Azure: `az account show`
- ✅ GitHub Actions workflow already set up
- ✅ Azure subscription access

---

## Part 1: Create Azure Storage Account for Terraform State

### Step 1: Set Variables

Replace these with YOUR values:

```bash
# Your environment
ENVIRONMENT="dev"                           # dev, staging, or prod
SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # YOUR subscription

# Names for resources (customize as needed)
RESOURCE_GROUP_NAME="terraform-state-${ENVIRONMENT}"   # e.g., terraform-state-dev
STORAGE_ACCOUNT_NAME="tfstate${ENVIRONMENT}123"        # e.g., tfstatedev123
LOCATION="eastus"                           # Azure region
CONTAINER_NAME="${ENVIRONMENT}-state"       # e.g., dev-state
```

**📝 Get your subscription ID:**
```bash
az account list --output table
# Copy the SubscriptionId column
```

### Step 2: Create Resource Group

```bash
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION"

# Output: Successfully created resource group 'terraform-state-dev' in location 'eastus'
```

### Step 3: Create Storage Account

```bash
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2

# Output: Successfully created storage account 'tfstatedev123'
```

**🔒 Security features enabled:**
- `--https-only true` — Only allow encrypted connections
- `--min-tls-version TLS1_2` — Enforce modern TLS
- `--sku Standard_LRS` — Redundant storage

### Step 4: Create Blob Container

```bash
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME"

# Output: Successfully created storage container 'dev-state'
```

### Step 5: Get Storage Account Access Key

```bash
az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query '[0].value' \
  --output tsv

# Output: DefaultEndpointsProtocol=https;... (long string)
# Copy this entire string ← This is your ARM_ACCESS_KEY
```

---

## Part 2: Set Up GitHub Secrets

### Step 1: Add Secrets to GitHub Environment

1. Go to your Application repository on GitHub
2. **Settings → Environments** 
3. Select your environment: **dev**, **staging**, or **prod**
4. Click **Environment secrets**
5. Add secret: **ARM_ACCESS_KEY**
   - **Name:** `ARM_ACCESS_KEY`
   - **Value:** Paste the access key from Step 5 above

**Result:**
```
✓ Secret created
  ARM_ACCESS_KEY = (encrypted)
```

---

## Part 3: Configure Backend in Your Repository

### Step 1: Copy Template

Copy the backend template to your application repository:

```bash
# From platform repo
cp GitHub_Actions_Platform/terraform-modules/backend.tf.template \
   GitHub_Actions_Application/backend.tf
```

### Step 2: Customize backend.tf

Edit `backend.tf` and replace placeholder values:

**Before:**
```hcl
backend "azurerm" {
  resource_group_name  = "replace-with-your-rg-name"
  storage_account_name = "replacewithstorageacctname"
  container_name       = "terraform-state"
  key                  = "terraform.tfstate"
}
```

**After (example for dev environment):**
```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-dev"    # Your RG from Step 1
  storage_account_name = "tfstatedev123"          # Your storage account
  container_name       = "dev-state"              # Your container
  key                  = "storage.tfstate"        # Unique name for this resource
}
```

**📌 Key naming convention:**
- Storage: `storage-account.tfstate`
- VMs: `virtual-machines.tfstate`
- Load Balancer: `load-balancer.tfstate`

### Step 3: Initialize Terraform with Backend

```bash
# Set environment variable (GitHub Actions does this automatically)
export ARM_ACCESS_KEY="your-storage-account-key-here"

# Initialize Terraform with backend
cd GitHub_Actions_Application
terraform init

# Output:
# Initializing Terraform Backend
# Do you want to copy existing state to the new backend?
# Answer: yes (if you have existing state)
#
# Successfully configured the backend "azurerm"!
# Terraform has been successfully initialized!
```

---

## Part 4: Verify Backend Setup

### Check Backend Is Working

```bash
# List current state
terraform state list

# Example output:
# azurerm_resource_group.main
# azurerm_storage_account.main

# Show state details
terraform state show azurerm_resource_group.main

# Verify state is in Azure (not local)
ls -la terraform.tfstate*  # Should NOT exist (state is in Azure)
```

### Check Azure Storage

```bash
# List blobs in container (backup verification)
az storage blob list \
  --container-name "dev-state" \
  --account-name "tfstatedev123" \
  --account-key "your-key-here"

# Output: Should show terraform.tfstate and terraform.tfstate.backup
```

---

## Part 5: Using Backend in Workflows

Your GitHub Actions workflows automatically use backend when they run:

```yaml
jobs:
  deploy-storage:
    environment: dev  # ← Automatically loads dev secrets including ARM_ACCESS_KEY
    steps:
      - name: Terraform Init
        run: terraform init
        env:
          ARM_ACCESS_KEY: ${{ secrets.ARM_ACCESS_KEY }}
          # GitHub automatically passes this to terraform
      
      - name: Terraform Plan
        run: terraform plan
```

---

## Troubleshooting

### Error: `backend initialization required`

**Problem:** You have a local `terraform.tfstate` file

**Solution:**
```bash
# Remove local state (backup first!)
cp terraform.tfstate terraform.tfstate.backup
rm terraform.tfstate terraform.tfstate.*

# Reinitialize
terraform init
```

### Error: `InvalidResourceName: The specified blob name is invalid`

**Problem:** Backend `key` value has invalid characters

**Solution:** Use only alphanumeric and underscores:
```hcl
# ❌ WRONG
key = "storage-account.tfstate"

# ✅ CORRECT
key = "storage_account.tfstate"
```

### Error: `StorageAccountNotFound`

**Problem:** Storage account name is wrong or doesn't exist

**Solution:** Verify your storage account exists:
```bash
az storage account show --name tfstatedev123 --resource-group terraform-state-dev
```

### Error: `SharedAccessSignatureExpired`

**Problem:** ARM_ACCESS_KEY is expired or invalid

**Solution:** Get a fresh key:
```bash
az storage account keys list \
  --resource-group "terraform-state-dev" \
  --account-name "tfstatedev123" \
  --query '[0].value' \
  --output tsv
```

Then update GitHub secret.

---

## Security Best Practices

### ✅ DO

- ✅ Use different storage accounts per environment (dev, staging, prod)
- ✅ Rotate access keys annually
- ✅ Enable storage account soft delete
- ✅ Use HTTPS only (`--https-only true`)
- ✅ Store ARM_ACCESS_KEY in GitHub Secrets (never in code)
- ✅ Enable versioning on storage account (automatic rollback)

### ❌ DON'T

- ❌ Commit `backend.tf` with real values (use templates)
- ❌ Share access keys in emails/chat
- ❌ Use same storage account for multiple organizations
- ❌ Store backup local state files in git
- ❌ Enable public access to storage container

---

## Enable Versioning & Soft Delete (Optional but Recommended)

### Enable Blob Versioning

```bash
az storage account blob-service-properties update \
  --resource-group "terraform-state-dev" \
  --account-name "tfstatedev123" \
  --enable-versioning true

# Result: Can restore previous state versions
```

### Enable Soft Delete

```bash
az storage account blob-service-properties update \
  --resource-group "terraform-state-dev" \
  --account-name "tfstatedev123" \
  --enable-delete-retention true \
  --delete-retention-days 7

# Result: Can recover deleted blobs for 7 days
```

---

## Next Steps

1. ✅ Create Azure storage account (Part 1)
2. ✅ Add ARM_ACCESS_KEY to GitHub Secrets (Part 2)
3. ✅ Configure backend.tf (Part 3)
4. ✅ Run `terraform init` (Part 3, Step 3)
5. ✅ Verify setup (Part 4)
6. ✅ Run your first workflow deployment

---

## Support

**Having issues?** Check:
1. [Terraform Azure Backend Docs](https://www.terraform.io/language/settings/backends/azurerm)
2. [Azure CLI Storage Account](https://learn.microsoft.com/en-us/cli/azure/storage/account)
3. Platform repo `README.md` for workflow examples
4. `PRE_DEPLOYMENT_CHECKLIST.md` for validation steps

---

## Reference: Complete Setup Commands

Copy-paste ready commands (customize variables first):

```bash
#!/bin/bash

# Configuration
ENVIRONMENT="dev"
SUBSCRIPTION_ID="your-subscription-id-here"
RESOURCE_GROUP_NAME="terraform-state-${ENVIRONMENT}"
STORAGE_ACCOUNT_NAME="tfstate${ENVIRONMENT}123"
LOCATION="eastus"
CONTAINER_NAME="${ENVIRONMENT}-state"

# Create resource group
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION"

# Create storage account
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --min-tls-version TLS1_2

# Create container
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME"

# Enable versioning
az storage account blob-service-properties update \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --enable-versioning true

# Get access key and display
echo "===== COPY THIS KEY TO GITHUB SECRETS ====="
az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query '[0].value' \
  --output tsv
echo "===== ARM_ACCESS_KEY (above) ====="
```

---

**Created:** March 18, 2026  
**Version:** 1.0  
**Status:** Final
