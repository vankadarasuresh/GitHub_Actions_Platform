# Complete GitHub Actions & Terraform Deployment System

## 🚀 Quick Start (Choose Your Path)

**User wanting to deploy infrastructure?** → Copy [examples/storage-account-deployment/](./examples/storage-account-deployment/) and run `terraform apply` (5 min)

**New to this system?** → Read [SYSTEM_SUMMARY.md](./SYSTEM_SUMMARY.md) (15 min)

**Want cheat sheet?** → Read [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) (2 min)

**Need full setup guide?** → Read [examples/DOCUMENTATION_GUIDE.md](./examples/DOCUMENTATION_GUIDE.md) (20 min)

---

## Executive Summary

This repository contains a **complete, production-ready infrastructure-as-code (IaC) system** for deploying Azure resources via GitHub Actions workflows. The system is designed for organizations with:

- **Platform teams** managing reusable infrastructure templates
- **Multiple application teams** consuming those templates
- **Multi-environment support** (dev, staging, production)
- **Enterprise security requirements** (RBAC, managed identities, encryption)

### What's Included

✅ **5 GitHub Actions Workflows** - Platform and application deployment pipelines
✅ **4 Production-Ready Terraform Modules** - Resource Group, Storage, VMs, Load Balancer
✅ **27 tfvars Configuration Files** - Dev/staging/prod environments
✅ **11 Documentation Guides** - Architecture, setup, examples, troubleshooting
✅ **Application Templates** - Quick-start for app teams
✅ **Complete Examples** - Real-world deployment scenarios

### Key Architecture Change (Recent Refactoring)

✨ **Resource groups are now centralized!**
- Single `resource-group` module creates the foundation
- All other modules (storage, VMs, LB) use resource group outputs as inputs
- No more duplicate resource group creation
- Consistent naming, tagging, and location across all resources

---

## 📚 Documentation Map (Pick Your Starting Point)

| Role | Goal | Read | Time |
|------|------|------|------|
| **Infrastructure User** | Deploy resources to Azure | [USER_REPO_PATTERN.md](./examples/USER_REPO_PATTERN.md) | 20 min |
| **Learning Terraform** | Understand the system | [COMPLETE_ARCHITECTURE.md](./examples/COMPLETE_ARCHITECTURE.md) | 20 min |
| **Platform Architect** | Understand & customize modules | [SYSTEM_SUMMARY.md](./SYSTEM_SUMMARY.md) | 15 min |
| **Need Quick Ref** | Cheat sheet & commands | [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | 2 min |
| **Ready to Deploy** | Copy working example | [examples/storage-account-deployment/](./examples/storage-account-deployment/) | 5 min |
| **Multi-Environment** | Dev/staging/prod configs | [SCENARIOS.md](./examples/storage-account-deployment/SCENARIOS.md) | 15 min |
| **Module Details** | Specific module docs | [platform/terraform-modules/](./platform/terraform-modules/) | As needed |

📍 **All Getting Started docs are in [examples/DOCUMENTATION_GUIDE.md](./examples/DOCUMENTATION_GUIDE.md)**

---

## ✨ What's New - Centralized Resource Groups

### The Change
- ✅ **New `resource-group` module** - Creates Azure resource groups (foundation)
- ✅ **Refactored all modules** - Storage, VMs, Load Balancer now use resource group outputs
- ✅ **No duplication** - Resource group created once, used by all resources

### The Benefits
| Before ❌ | After ✅ |
|-----------|----------|
| Each module created its own RG | One RG per environment |
| Duplicate RG names/tags | Consistent naming & tagging |
| Complex dependencies | Clean dependency chain |
| Difficult to maintain | Single source of truth |

### How It Works Now
```
User → Calls modules from GitHub_Actions
       ↓
       Step 1: resource-group module (creates RG)
       ↓ Outputs: RG name, location, tags
       ↓
       Step 2: storage-account module (uses RG outputs)
       Step 3: virtual-machines module (uses RG outputs)
       Step 4: load-balancer module (uses RG outputs)
```

**Learn more**: [MODULE_DEPENDENCY_GUIDE.md](./examples/MODULE_DEPENDENCY_GUIDE.md)

---

## 📁 Directory Structure

```
GitHub_Actions/
│
├── SYSTEM_SUMMARY.md                        ← START HERE (Overview)
├── QUICK_REFERENCE.md                       ← Cheat sheet
│
├── examples/                                ← Documentation & Working Examples
│   ├── DOCUMENTATION_GUIDE.md               (Navigation guide)
│   ├── COMPLETE_ARCHITECTURE.md             (System design)
│   ├── USER_REPO_PATTERN.md                 (How users call modules)
│   ├── MODULE_DEPENDENCY_GUIDE.md           (Dependency chain)
│   └── storage-account-deployment/          (Ready-to-copy example)
│       ├── main.tf, variables.tf, terraform.tfvars, outputs.tf
│       ├── README.md, SCENARIOS.md, backend.tf.example
│       └── .gitignore
│
├── .github/
│   └── workflows/
│       ├── platform-deploy-storage.yml           (Reusable: Storage)
│       ├── platform-deploy-vm.yml               (Reusable: VMs)
│       ├── platform-deploy-loadbalancer.yml     (Reusable: Load Balancer)
│       ├── app-deploy-infrastructure.yml        (App workflow: Auto-trigger)
│       └── app-deploy-manual.yml                (App workflow: Manual dispatch)
│
├── platform/
│   ├── README.md                              (Module overview & integration guide)
│   └── terraform-modules/
│       ├── resource-group/                   ← NEW: Foundation module
│       │   ├── main.tf, variables.tf, outputs.tf, README.md
│       ├── storage-account/                  ← Refactored: Uses RG module
│       │   ├── main.tf, variables.tf, outputs.tf, README.md
│       ├── virtual-machines/                 ← Refactored: Uses RG module
│       │   ├── main.tf, variables.tf, outputs.tf, README.md
│       └── load-balancer/                    ← Refactored: Uses RG module
│           ├── main.tf, variables.tf, outputs.tf, README.md
│
├── applications/
│   ├── EXAMPLE_APP_TERRAFORM_CONFIG.md      (Full terraform config template)
│   ├── APP_TEAM_QUICK_START.md              (5-min setup guide)
│   └── APP_TEAM_DEPLOYMENT_CHECKLIST.md     (Complete deployment checklist)
│
├── tfvars/
│   ├── dev/, staging/, prod/
│   │   ├── common.tfvars
│   │   ├── storage.tfvars
│   │   ├── vms.tfvars
│   │   └── loadbalancer.tfvars
│
├── docs/
│   ├── AZURE_AUTHENTICATION.md               (Auth setup: 3 options explained)
│   ├── WORKFLOW_ARCHITECTURE.md              (System design & data flow)
│   ├── APP_TEAM_SETUP.md                    (Onboarding guide)
│   ├── TERRAFORM_OUTPUTS.md                 (Output reference)
│   ├── TERRAFORM_MODULES_EXAMPLE.md         (Module usage examples)
│   ├── COMPLETE_END_TO_END_EXAMPLE.md       (Real-world walkthrough)
│   └── IMPLEMENTATION_GUIDE.md               (Deployment checklist)
│
└── README.md (This file)

```

## 🚀 Quick Start

### For Platform Teams (5 steps)

1. **Create Azure Service Principal**
   ```bash
   az ad sp create-for-rbac --name "platform-github-actions" --role Contributor
   # Save: Client ID, Client Secret, Tenant ID, Subscription ID
   ```

2. **Create Terraform State Backend**
   ```bash
   az group create -n terraform-state-rg -l eastus
   az storage account create -n tfstaternd2024 -g terraform-state-rg --sku Standard_LRS
   az storage container create -n tfstate --account-name tfstaternd2024
   ```

3. **Add GitHub Secrets** (Settings → Secrets and Variables → Actions)
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`
   - `TF_STATE_RG` = terraform-state-rg
   - `TF_STATE_SA` = tfstaternd2024
   - `TF_STATE_CONTAINER` = tfstate

4. **Test Platform Workflows** - Merge to main to trigger deployment

5. **Distribute to App Teams** - Share platform workflow URLs in documentation

**Time to completion:** 30 minutes

### For Application Teams (5 steps)

1. **Copy Template Files**
   ```bash
   mkdir terraform tfvars/{dev,staging,prod} .github/workflows
   # Copy terraform/ files from applications/EXAMPLE_APP_TERRAFORM_CONFIG.md
   # Copy tfvars/ files from platform/tfvars/
   ```

2. **Customize Configuration**
   - Edit `terraform/main.tf` with your resource names
   - Edit tfvars files for your environments
   - Update `applications/` resource names

3. **Create GitHub Workflow**
   ```bash
   # Copy .github/workflows/app-deploy-infrastructure.yml
   # Customize for your resource names
   ```

4. **Add GitHub Secrets**
   - Same 6 secrets as platform team (share from organization secrets if available)

5. **Deploy** - `git push origin main` triggers workflow

**Time to completion:** 10 minutes per environment

Read: [APP_TEAM_QUICK_START.md](applications/APP_TEAM_QUICK_START.md)

## 🏗️ System Architecture

### Data Flow

```
Git Push → GitHub Actions → Terraform Init → Fetch Platform Modules
    ↓
Load tfvars Configuration Files
    ↓
Authenticate with Azure (Service Principal)
    ↓
Terraform Validate & Plan
    ↓
Manual Approval (Production Only)
    ↓
Terraform Apply
  - Storage Account creation
  - Virtual Machines creation
  - Network configuration
  - Load Balancer creation
    ↓
Capture & Output Results (IPs, FQDNs, connection strings)
    ↓
Application uses infrastructure
```

### Module Dependency Chain

```
1️⃣  Platform-Deploy-Storage
    └─ Output: Storage connection string

2️⃣  Platform-Deploy-VM
    └─ Output: network_interface_ids

3️⃣  Platform-Deploy-LoadBalancer (consumes VM output)
    └─ Output: Application endpoint (IP + FQDN)
```

## 📚 Documentation Map

| Document | Purpose | For Whom |
|----------|---------|----------|
| [AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md) | 3 auth methods, troubleshooting, automation scripts | Platform engineers |
| [WORKFLOW_ARCHITECTURE.md](docs/WORKFLOW_ARCHITECTURE.md) | System design, data flow, integration patterns | Architects |
| [APP_TEAM_SETUP.md](docs/APP_TEAM_SETUP.md) | Onboarding, step-by-step setup | App teams |
| [TERRAFORM_OUTPUTS.md](docs/TERRAFORM_OUTPUTS.md) | Complete output reference for each module | Devs using outputs |
| [TERRAFORM_MODULES_EXAMPLE.md](docs/TERRAFORM_MODULES_EXAMPLE.md) | Example code for each module | Terraform users |
| [COMPLETE_END_TO_END_EXAMPLE.md](docs/COMPLETE_END_TO_END_EXAMPLE.md) | Real production deployment walkthrough | All teams |
| [IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md) | Step-by-step implementation checklist | Implementation teams |
| [APP_TEAM_QUICK_START.md](applications/APP_TEAM_QUICK_START.md) | 5-minute app team setup | Application teams |
| [APP_TEAM_DEPLOYMENT_CHECKLIST.md](applications/APP_TEAM_DEPLOYMENT_CHECKLIST.md) | 12-phase deployment checklist | Project managers |
| [platform/README.md](platform/README.md) | Module integration & customization | All teams |

## 🎯 Key Features

### Platform Modules

✅ **Modular Design** - Each module independent and reusable
✅ **Comprehensive Inputs** - 20-25 variables per module for customization
✅ **Validated Outputs** - All outputs properly typed and documented
✅ **Production Standards** - Security, monitoring, encryption support
✅ **Environment Flexibility** - Same module supports dev/staging/prod

### Workflows

✅ **Reusable Workflows** - Called from multiple apps via GitHub Actions
✅ **Auto-Trigger** - Automatic deployment on branch push
✅ **Manual Dispatch** - Trigger deployment on-demand
✅ **Approval Gates** - Production requires peer review
✅ **Parallel Jobs** - Fastest execution with terraform caching

### Enterprise Features

✅ **Azure RBAC** - Managed identities for VMs
✅ **Network Security** - Network security groups, health probes
✅ **Encryption** - Optional customer-managed keys for storage
✅ **Monitoring** - Diagnostics support for all resources
✅ **High Availability** - Geo-redundant storage, load balancer health checks
✅ **Cost Optimization** - Environment-specific configurations (LRS for dev, GRS for prod)
✅ **Compliance** - TLS 1.2+, audit logging, soft delete policies

## 💰 Cost Examples

### Development Environment
```
Storage Account (LRS)     = $1-5/month
1-2 Small VMs (B2s)       = $30-60/month
Load Balancer             = $16/month
                ─────────────────────
Total                     = ~$50/month
```

### Production Environment
```
Storage Account (GRS)     = $30-50/month
4 Standard VMs (D2s_v3)   = $300-400/month
Load Balancer             = $16/month
                ─────────────────────
Total                     = ~$350/month
```

## 🔐 Authentication Methods

The system supports **3 Azure authentication methods**:

| Method | Security | Rotation | Best For |
|--------|----------|----------|----------|
| **Service Principal + Secret** | Medium | Manual | Quick setup |
| **Federated Identity (OIDC)** | High | Automatic | Organizations |
| **Per-Team Service Principals** | Very High | Manual per team | Large orgs |

See [AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md) for detailed setup instructions.

## 🧩 Module Reference

### Storage Account Module
```hcl
module "storage" {
  source = "../../platform/terraform-modules/storage-account"
  
  storage_account_name     = "stgmyapp001"
  account_replication_type = "GRS"  # LRS for dev, GRS for prod
  create_containers        = true
  container_names          = ["data", "logs"]
}

# Outputs: connection_string, endpoints, access_keys
```

### Virtual Machines Module
```hcl
module "vms" {
  source = "../../platform/terraform-modules/virtual-machines"
  
  vm_count              = 4           # 1 for dev, 4 for prod
  vm_size               = "Standard_D2s_v3"
  admin_username        = "azureuser"
  admin_ssh_public_key  = file(var.ssh_key)
  enable_system_managed_identity = true
}

# Outputs: network_interface_ids (→ Load Balancer), vm_private_ips
```

### Load Balancer Module
```hcl
module "load_balancer" {
  source = "../../platform/terraform-modules/load-balancer"
  
  backend_pool_ids = module.vms.network_interface_ids  # From VMs
  
  enable_http_rule  = true
  enable_https_rule = false  # true for prod
  health_probe_path = "/api/health"
}

# Outputs: loadbalancer_public_ip_address, loadbalancer_fqdn
```

## 🐛 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Module not found" | Wrong path to platform modules | Verify `../../platform/terraform-modules/` exists from terraform/ |
| "Authentication failed" | Missing/wrong GitHub secrets | Check all 6 secrets are set correctly in Settings |
| "Backend not found" | State storage doesn't exist | Create: `az storage account create ...` |
| "Resource already exists" | Resource exists in Azure | Delete or `terraform import` to state |
| "Workflow didn't trigger" | Branch/path filter doesn't match | Check trigger conditions in workflow file |

See [COMPLETE_END_TO_END_EXAMPLE.md](docs/COMPLETE_END_TO_END_EXAMPLE.md) for detailed troubleshooting.

## 📋 Implementation Checklist

- [ ] **Platform Team Setup** (30 min)
  - [ ] Create Service Principal
  - [ ] Create Terraform state backend
  - [ ] Add GitHub secrets
  - [ ] Test platform workflows

- [ ] **App Team Setup** (10 min per environment)
  - [ ] Copy terraform files
  - [ ] Create tfvars files
  - [ ] Create GitHub workflows
  - [ ] Add GitHub secrets
  - [ ] Deploy to dev

See [APP_TEAM_DEPLOYMENT_CHECKLIST.md](applications/APP_TEAM_DEPLOYMENT_CHECKLIST.md) for comprehensive 12-phase checklist.

## 📖 Next Steps

**Platform Teams:**
1. Read [AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md)
2. Run [IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md)
3. Share workflows with app teams

**Application Teams:**
1. Read [APP_TEAM_QUICK_START.md](applications/APP_TEAM_QUICK_START.md)
2. Copy template from [EXAMPLE_APP_TERRAFORM_CONFIG.md](applications/EXAMPLE_APP_TERRAFORM_CONFIG.md)
3. Deploy!

**DevOps/SRE:**
1. Review [WORKFLOW_ARCHITECTURE.md](docs/WORKFLOW_ARCHITECTURE.md)
2. Set up monitoring and alerts
3. Plan disaster recovery

## ✨ Highlights

🎯 **End-to-End Solution** - Everything from auth to deployment
🔗 **Modular Architecture** - Reuse platform modules across all apps
📊 **Real-World Examples** - Learn from complete production scenarios
🛡️ **Enterprise Security** - RBAC, managed identities, encryption
💡 **Well Documented** - 9 comprehensive guides covering all aspects
⚡ **Quick Start** - Get app deployed in under 15 minutes
🔄 **Auto-Updates** - Change tfvars, push code, automatic deployment
👥 **Multi-Team Support** - Platform teams + multiple app teams

## 📞 Support

- Check relevant **documentation file** for your question
- Review module **README.md** files in `platform/terraform-modules/`
- See [COMPLETE_END_TO_END_EXAMPLE.md](docs/COMPLETE_END_TO_END_EXAMPLE.md) for troubleshooting

## 📦 Version Information

- **Terraform**: 1.5.0+
- **Azure Provider**: 3.0+
- **GitHub Actions**: Latest
- **Azure CLI**: 2.40+

## 📝 License

Enterprise infrastructure-as-code template. Customize for your organization's governance policies.

---

**Last Updated**: 2024
**Maintained By**: Platform Engineering Team
├── dev/
│   ├── storage-account.tfvars
│   ├── virtual-machines.tfvars
│   └── load-balancer.tfvars
├── staging/
│   └── (same files)
└── prod/
    └── (same files)

terraform/
├── storage-account/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
├── virtual-machines/
│   └── (similar structure)
└── load-balancer/
    └── (similar structure)

docs/
├── AZURE_AUTHENTICATION.md      # 3 auth options (Service Principal, Federated Identity, Per-Team)
├── WORKFLOW_ARCHITECTURE.md     # Architecture, data flow, best practices
└── APP_TEAM_SETUP.md            # Step-by-step for application teams
```

## 🔄 Workflow Execution Flow

```
Branch Push or Manual Trigger
           │
           ├─→ Determine Environment (dev/staging/prod)
           │
           ├─→ Deploy Storage Account
           │
           ├─→ Deploy Virtual Machines
           │   (Parallel with Storage)
           │
           └─→ Deploy Load Balancer
               (Uses VM outputs)
               │
               └─→ Deployment Summary Report
```

## 📊 Workflow Details

### Platform Workflows (Reusable)

| Workflow | Purpose | Inputs | Outputs |
|----------|---------|--------|---------|
| `platform-deploy-storage.yml` | Deploy Azure Storage Account | environment, tfvars_file, terraform_version | storage_account_id, storage_account_name, connection_string |
| `platform-deploy-vm.yml` | Deploy Azure VMs | environment, tfvars_file, terraform_version | vm_ids, vm_private_ips, vm_public_ips, network_interface_ids |
| `platform-deploy-loadbalancer.yml` | Deploy Load Balancer | environment, tfvars_file, terraform_version, backend_pool_ids | loadbalancer_id, loadbalancer_frontend_ip, loadbalancer_fqdn |

### Application Workflows

| Workflow | Trigger | Use Case |
|----------|---------|----------|
| `app-deploy-infrastructure.yml` | Push to main/develop or manual dispatch | Automatic deployment based on branch |
| `app-deploy-manual.yml` | Manual workflow dispatch | On-demand deployment with resource selection |

## 🔐 Azure Authentication Options

### Option 1: Service Principal with Secret (Recommended for Multi-team)
- Create one service principal per environment
- Store client secret in GitHub secrets
- **Pro:** Simple, works everywhere
- **Con:** Requires secret rotation every 90 days

### Option 2: Federated Identity (Most Secure)
- Use OpenID Connect (OIDC) tokens
- No long-lived secrets stored
- **Pro:** Highly secure, no secret rotation
- **Con:** Requires more setup

### Option 3: Per-App-Team Service Principals
- Each team gets isolated service principal
- Fine-grained access control
- **Pro:** Audit trail per team
- **Con:** More service principals to manage

**→ See [docs/AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md) for detailed setup**

## 📈 Common Scenarios

### Scenario 1: Automatic Dev Deployment
```bash
git checkout develop
# Edit tfvars/dev/* files
git commit -am "Update dev config"
git push origin develop
# ✓ Workflow auto-triggers, deploys to dev
```

### Scenario 2: Production Deployment with Approval
```bash
git checkout main
# Edit tfvars/prod/* files
git commit -am "Production release v1.0"
git push origin main
# ⏳ Workflow requires reviewer approval
# ✓ Once approved, deployment proceeds
```

### Scenario 3: Manual Deployment
- Go to **Actions → Application - Deploy with Manual Selection**
- Select environment, app name, resources
- Click "Run workflow"
- **✓ Custom deployment executed**

## 🛠️ Key Features

✅ **Reusable Workflows** - Share across multiple repositories  
✅ **Parallel Execution** - Storage and VM deploy in parallel  
✅ **Output Chaining** - VM outputs fed to Load Balancer  
✅ **Environment Separation** - Dev, staging, prod with different configs  
✅ **Approval Gates** - Require approval for production deployments  
✅ **Terraform Plan** - Review before applying changes  
✅ **Deployment Summary** - All outputs captured and reported  
✅ **Error Handling** - Validation and error reporting  

## 📋 Prerequisites

- **GitHub:** Repository with GitHub Actions enabled
- **Azure:** Subscription with permissions to create resources
- **Terraform:** Version 1.5.0+
- **CLI:** Azure CLI installed locally

## 🔧 Setup Steps

### 1. Set Up Azure Authentication (Platform Team)

```bash
cd docs
cat AZURE_AUTHENTICATION.md
# Choose Option 1, 2, or 3
# Run setup commands
# Save secrets for distribution
```

### 2. Configure GitHub Secrets (Each Team)

```
Settings → Secrets and variables → Actions

Add secrets:
- AZURE_CREDENTIALS
- AZURE_CLIENT_ID
- AZURE_CLIENT_SECRET
- AZURE_SUBSCRIPTION_ID
- AZURE_TENANT_ID
```

### 3. Customize tfvars Files

Edit tfvars files for your infrastructure:
- `tfvars/dev/storage-account.tfvars`
- `tfvars/dev/virtual-machines.tfvars`
- `tfvars/dev/load-balancer.tfvars`
- `tfvars/prod/*` (similar)

### 4. Create Terraform Modules

Create Terraform code:
- `terraform/storage-account/` - Storage module with outputs
- `terraform/virtual-machines/` - VM module with outputs
- `terraform/load-balancer/` - LB module with outputs

### 5. Deploy!

```bash
# For dev:
git push origin develop

# For prod:
git push origin main
```

## 📚 Documentation

| Document | Purpose | Audience |
|----------|---------|----------|
| [AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md) | Set up Azure auth (3 options) | Platform teams, Infrastructure admins |
| [WORKFLOW_ARCHITECTURE.md](docs/WORKFLOW_ARCHITECTURE.md) | System design and data flow | DevOps engineers, tech leads |
| [APP_TEAM_SETUP.md](docs/APP_TEAM_SETUP.md) | Step-by-step team onboarding | Application teams, developers |

## 🚨 Troubleshooting

### Workflow Won't Trigger
```
✓ Check if secrets are configured
✓ Verify branch matches trigger conditions
✓ Check if .github/workflows/ files exist
```

### Terraform Plan Fails
```
✓ Verify tfvars file syntax
✓ Check Azure credentials
✓ Ensure resource group exists
```

### Azure Login Fails
```
✓ Regenerate service principal secret
✓ Verify role assignments
✓ Check subscription ID
```

→ See [WORKFLOW_ARCHITECTURE.md - Troubleshooting](docs/WORKFLOW_ARCHITECTURE.md#troubleshooting)

## 🔒 Security Best Practices

✅ **Use Federated Identity** when possible (no secrets)  
✅ **Per-environment Service Principals** for audit trails  
✅ **Scope roles to Resource Groups** (not subscription)  
✅ **Rotate secrets every 90 days** if using secrets  
✅ **Enable approval gates for prod** to catch errors  
✅ **Review deployment plans** in pull requests  
✅ **Never commit secrets** to version control  
✅ **Use separate service principals per team** for isolation  

## 🎯 Next Steps

1. **Platform Team:**
   - [ ] Read [AZURE_AUTHENTICATION.md](docs/AZURE_AUTHENTICATION.md)
   - [ ] Choose authentication method
   - [ ] Create service principals
   - [ ] Generate and distribute secrets

2. **App Teams:**
   - [ ] Read [APP_TEAM_SETUP.md](docs/APP_TEAM_SETUP.md)
   - [ ] Copy workflows to your repos
   - [ ] Store secrets
   - [ ] Create tfvars files
   - [ ] Create Terraform modules
   - [ ] Test in dev, deploy to prod

## 📝 Example tfvars Files

Development environment example:
```hcl
# tfvars/dev/storage-account.tfvars
environment         = "dev"
location            = "eastus"
resource_group_name = "rg-myapp-dev"
storage_account_name = "stgmyappdev001"
account_tier         = "Standard"
account_replication_type = "LRS"  # Cost-effective
```

Production environment example:
```hcl
# tfvars/prod/storage-account.tfvars
environment         = "prod"
location            = "eastus"
resource_group_name = "rg-myapp-prod"
storage_account_name = "stgmyappprod001"
account_tier         = "Standard"
account_replication_type = "GRS"  # High availability
```

## 🎓 Learning Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [GitHub Actions Reusable Workflows](https://docs.github.com/actions/using-workflows/reusing-workflows)
- [Azure Login GitHub Action](https://github.com/Azure/login)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Federated Identity Credentials](https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)

## 📞 Support

For questions or issues:
1. Check documentation in `/docs`
2. Review workflow logs in GitHub Actions
3. Contact platform team
4. Create GitHub issue with details

## 📄 License

Use freely for your organization.

---

**Created:** March 2026  
**Maintained by:** Platform Team  
**Last Updated:** March 13, 2026
