# Quick Reference Card

## TL;DR - The Simplest Explanation

```
Platform Team:     Creates reusable modules
                          ↓
              GitHub_Actions/platform/terraform-modules/
              ├─ resource-group/
              ├─ storage-account/
              ├─ virtual-machines/
              └─ load-balancer/

              
User's Team:       Calls modules from their own repo
                          ↓
              my-infrastructure/environments/{dev,staging,prod}/
              ├─ main.tf (calls modules)
              ├─ variables.tf
              └─ terraform.tfvars

How it works:
1. User calls resource-group module (creates RG)
2. User calls storage-account module (uses RG name as input)
3. RG outputs flow to other modules
4. All resources have consistent tags and location
```

---

## One-Command Reference

### User's Complete main.tf (Minimal Version)

```hcl
terraform {
  required_providers {
    azurerm = { version = "~> 3.0" }
  }
}

provider "azurerm" {
  features {}
}

# STEP 1: Create Resource Group
module "resource_group" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/resource-group?ref=main"
  
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# STEP 2: Create Storage Account (uses RG outputs)
module "storage_account" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/storage-account?ref=main"
  
  # ← CRITICAL: Pass RG outputs as inputs
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags
  
  storage_account_name     = var.storage_account_name
  account_replication_type = "GRS"
  
  depends_on = [module.resource_group]
}

# OPTIONAL STEP 3: Create VMs
module "virtual_machines" {
  source = "git::https://github.com/org/GitHub_Actions.git//platform/terraform-modules/virtual-machines?ref=main"
  
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  tags                = module.resource_group.tags
  environment         = var.environment
  
  vm_count = 2
  
  depends_on = [module.resource_group]
}
```

---

## Variables.tf Essentials

```hcl
# Resource Group Variables
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }

# Resource Variables
variable "storage_account_name" { type = string }
variable "account_replication_type" { type = string; default = "GRS" }
```

---

## Terraform.tfvars Template

```hcl
environment         = "prod"
location            = "eastus"
resource_group_name = "rg-myapp-prod"
storage_account_name = "stgmyappprod001"

tags = {
  Environment = "production"
  Team        = "platform"
  CostCenter  = "engineering"
}
```

---

## Deploy Steps (4 Commands)

```bash
# Navigate to your environment
cd my-infrastructure/environments/prod

# Initialize (download modules)
terraform init

# Review changes
terraform plan

# Deploy (creates RG first, then resources)
terraform apply
```

---

## Module Outputs (How to Use Them)

```hcl
# From resource-group module:
module.resource_group.resource_group_name    ← Pass to storage/vms/lb
module.resource_group.location               ← Pass to storage/vms/lb
module.resource_group.tags                   ← Pass to storage/vms/lb

# From storage-account module:
module.storage_account.storage_account_name
module.storage_account.primary_access_key
module.storage_account.primary_blob_endpoint
```

---

## The Golden Rule

```
❌ DON'T:                          ✅ DO:
==================================================================================================
Create RG in each module          Create RG ONCE in resource-group module

Call storage without passing      Pass module.resource_group.resource_group_name
RG name                          to storage-account module

Hardcode resource_group_name      Use: resource_group_name = var.resource_group_name
                                 (pass from resource-group output)

Create multiple RGs               All resources in ONE RG per environment

Put secrets in tfvars            Store secrets in Azure Key Vault

Use local paths for modules       Use git::https:// references
```

---

## Common Mistakes & Fixes

### ❌ Error: "azurerm_resource_group.main not found"
**Cause**: Storage module still trying to create its own RG  
**Fix**: Remove RG creation from storage module, pass `resource_group_name = var.resource_group_name`

### ❌ Error: "storage account name already exists"
**Cause**: Storage account name not unique globally  
**Fix**: Add timestamp or random suffix: `storage_account_name = "stgmyapp${formatdate("DDMMYYhh", timestamp())}"`

### ❌ Error: "Module not found"
**Cause**: Wrong git URL or git SSH key not configured  
**Fix**: Verify URL: `git::https://github.com/your-org/GitHub_Actions.git//platform/terraform-modules/resource-group`

### ❌ Plan shows creating RG in wrong order
**Cause**: Missing `depends_on = [module.resource_group]`  
**Fix**: Add explicit dependency to storage/vm/lb modules

---

## Architecture in One Picture

```
┌───────────────────────────────────────┐
│  terraform apply (user runs this)     │
└───────────────────────────────────────┘
                 ↓
    ┌──────────────────────────┐
    │ Module: resource-group   │  ← Created FIRST
    │ Creates: Azure RG        │
    │ Outputs: RG name, loc    │
    └──────────────────────────┘
                 ↓
    ┌──────────────────────────┐
    │ Module: storage-account  │  ← Created SECOND
    │ Input: RG name from ↑    │
    │ Creates: Storage in RG   │
    └──────────────────────────┘
                 ↓
    ┌──────────────────────────┐
    │ Module: virtual-machines │  ← Created THIRD (optional)
    │ Input: RG name from ↑    │
    │ Creates: VMs in RG       │
    └──────────────────────────┘
```

---

## File Structure (Copy This)

```
my-infrastructure/
│
├── environments/
│   │
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   │
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   │
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
│
└── .gitignore
    └── *.tfstate*
        *.tfstate.*.backup
        .terraform/
```

---

## Module Reference URLs

```hcl
# Resource Group
source = "git::https://github.com/ORG/GitHub_Actions.git//platform/terraform-modules/resource-group?ref=main"

# Storage Account
source = "git::https://github.com/ORG/GitHub_Actions.git//platform/terraform-modules/storage-account?ref=main"

# Virtual Machines
source = "git::https://github.com/ORG/GitHub_Actions.git//platform/terraform-modules/virtual-machines?ref=main"

# Load Balancer
source = "git::https://github.com/ORG/GitHub_Actions.git//platform/terraform-modules/load-balancer?ref=main"

# Replace ORG with your organization name
```

---

## Documentation Links

| Need | Link |
|------|------|
| Where to start? | `examples/DOCUMENTATION_GUIDE.md` |
| Full architecture? | `examples/COMPLETE_ARCHITECTURE.md` |
| How to use modules? | `examples/USER_REPO_PATTERN.md` |
| Module dependencies? | `examples/MODULE_DEPENDENCY_GUIDE.md` |
| Ready example? | `examples/storage-account-deployment/` |
| Different configs? | `examples/storage-account-deployment/SCENARIOS.md` |

---

## Deployment Checklist

```
BEFORE you run terraform apply:

□ Created my own repository (not using GitHub_Actions directly)
□ Created environments/{dev,staging,prod} directories
□ Created main.tf with resource-group module FIRST
□ Created main.tf with storage-account module SECOND (uses RG outputs)
□ Added depends_on = [module.resource_group] to storage module
□ Created variables.tf with all needed variables
□ Created terraform.tfvars with my values
□ Updated module source URLs to my org
□ Reviewed terraform plan output
□ Confirmed no hardcoded RG names
□ Confirmed resource_group_name comes from variable
□ Confirmed storage module uses module.resource_group.resource_group_name

THEN run:
terraform init
terraform plan
terraform apply
```

---

## One-Liner Deploy (Everything at Once)

```bash
cd my-infrastructure/environments/prod && \
terraform init && \
terraform plan -out=tfplan && \
terraform apply tfplan
```

---

## Debugging Commands

```bash
# See what modules Terraform found
terraform init -upgrade

# Check module structure
ls -la .terraform/modules/

# See what will be created (detailed)
terraform plan -out=tfplan
cat tfplan

# Check current state
terraform state list
terraform state show module.resource_group

# Show all outputs
terraform output

# Show specific output
terraform output storage_account_name

# Destroy everything (if needed)
terraform destroy
```

---

## Key Phrases to Remember

```
"Resource group first, everything else second"
"Pass RG outputs to other modules"
"Use git references, not local paths"
"Same module, different tfvars for each environment"
"One RG per environment, all resources in that RG"
```

---

## Status Check

```bash
# Validate modules work
cd platform/terraform-modules/resource-group && terraform validate
cd ../storage-account && terraform validate
cd ../virtual-machines && terraform validate
cd ../load-balancer && terraform validate

# All should say: "Success! The configuration is valid."
```

---

**Print this card and keep it handy! 📋**

*Last Updated: March 16, 2026*
