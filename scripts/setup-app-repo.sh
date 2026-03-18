#!/bin/bash

################################################################################
# GitHub Actions Application Repository Setup Script
# 
# PURPOSE: Automates setup for application teams using the reusable platform
# 
# FEATURES:
# - Validates Azure CLI and GitHub CLI are installed
# - Verifies Azure credentials (service principal)
# - Creates Azure Storage backend for Terraform state
# - Validates repository structure
# - Provides GitHub Secrets configuration guide
#
# USAGE: bash setup-app-repo.sh [--validate-only]
#
# REQUIREMENTS:
# - Azure CLI (az) installed: https://docs.microsoft.com/cli/azure/install-azure-cli-macos
# - GitHub CLI (gh) installed: https://cli.github.com/
# - Logged in to Azure: az login
# - Logged in to GitHub: gh auth login
#
# AUTHOR: Platform Team
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script state
VALIDATE_ONLY=false
CURRENT_DIR=$(pwd)
REPO_NAME=$(basename "$CURRENT_DIR")

################################################################################
# HELPER FUNCTIONS
################################################################################

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC} $1"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "${BLUE}→${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed"
        echo "   Install from: $2"
        return 1
    fi
    print_success "$1 is installed"
    return 0
}

################################################################################
# VALIDATION FUNCTIONS
################################################################################

validate_prerequisites() {
    print_header "VALIDATING PREREQUISITES"
    
    local all_valid=true
    
    if ! check_command "az" "https://docs.microsoft.com/cli/azure/install-azure-cli-macos"; then
        all_valid=false
    fi
    
    if ! check_command "gh" "https://cli.github.com/"; then
        all_valid=false
    fi
    
    if ! check_command "terraform" "https://www.terraform.io/downloads"; then
        all_valid=false
    fi
    
    if [ "$all_valid" = false ]; then
        print_error "Please install missing prerequisites and try again"
        return 1
    fi
    
    print_success "All prerequisites installed"
}

validate_azure_login() {
    print_step "Checking Azure CLI authentication..."
    
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure"
        echo "   Run: az login"
        return 1
    fi
    
    local current_user=$(az account show --query user.name -o tsv)
    local subscription=$(az account show --query name -o tsv)
    
    print_success "Logged in as: $current_user"
    print_success "Subscription: $subscription"
}

validate_github_login() {
    print_step "Checking GitHub CLI authentication..."
    
    if ! gh auth status &> /dev/null; then
        print_error "Not logged in to GitHub"
        echo "   Run: gh auth login"
        return 1
    fi
    
    local github_user=$(gh api user --jq '.login')
    print_success "Logged in as: $github_user"
}

validate_repo_structure() {
    print_step "Validating repository structure..."
    
    local required_dirs=(
        ".github/workflows"
        "tfvars/dev"
        "tfvars/staging"
        "tfvars/prod"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            print_warning "Missing directory: $dir"
            mkdir -p "$dir"
            print_success "Created: $dir"
        fi
    done
    
    # Check for workflow files
    if [ ! -f ".github/workflows/deploy-storage.yml" ]; then
        print_warning "Missing: .github/workflows/deploy-storage.yml"
    else
        print_success "Found: .github/workflows/deploy-storage.yml"
    fi
}

################################################################################
# SETUP FUNCTIONS
################################################################################

setup_azure_backend() {
    print_header "CONFIGURING AZURE TERRAFORM STATE BACKEND"
    
    print_info "This script will create an Azure Storage Account for Terraform state"
    print_info "State will be stored per environment (dev, staging, prod)"
    
    # Get current subscription
    local subscription_id=$(az account show --query id -o tsv)
    local subscription_name=$(az account show --query name -o tsv)
    
    print_success "Using subscription: $subscription_name ($subscription_id)"
    
    # Prompt for resource group
    read -p "Enter Azure Resource Group name (for state storage): " rg_name
    if [ -z "$rg_name" ]; then
        rg_name="terraform-state-${REPO_NAME}"
        print_info "Using default: $rg_name"
    fi
    
    # Prompt for location
    read -p "Enter Azure region (default: eastus): " location
    location="${location:-eastus}"
    
    # Prompt for storage account name
    read -p "Enter Storage Account name (must be unique, lowercase, 3-24 chars): " storage_account
    if [ -z "$storage_account" ]; then
        storage_account="tfstate${REPO_NAME,,}"
        print_info "Using default: $storage_account"
    fi
    
    # Validate storage account name
    if ! [[ "$storage_account" =~ ^[a-z0-9]{3,24}$ ]]; then
        print_error "Invalid storage account name (must be lowercase alphanumeric, 3-24 chars)"
        return 1
    fi
    
    # Create resource group if it doesn't exist
    print_step "Checking/creating resource group: $rg_name"
    if ! az group show --name "$rg_name" &> /dev/null; then
        az group create --name "$rg_name" --location "$location"
        print_success "Created resource group: $rg_name"
    else
        print_success "Resource group already exists: $rg_name"
    fi
    
    # Create storage account if it doesn't exist
    print_step "Checking/creating storage account: $storage_account"
    if ! az storage account show --name "$storage_account" --resource-group "$rg_name" &> /dev/null; then
        az storage account create \
            --name "$storage_account" \
            --resource-group "$rg_name" \
            --location "$location" \
            --sku Standard_LRS \
            --kind StorageV2 \
            --https-only true \
            --min-tls-version TLS1_2
        print_success "Created storage account: $storage_account"
    else
        print_success "Storage account already exists: $storage_account"
    fi
    
    # Get access key
    print_step "Retrieving storage account access key..."
    local access_key=$(az storage account keys list \
        --resource-group "$rg_name" \
        --account-name "$storage_account" \
        --query '[0].value' -o tsv)
    
    # Create containers for each environment
    for env in dev staging prod; do
        local container_name="${env}-state"
        print_step "Creating blob container: $container_name"
        
        az storage container create \
            --name "$container_name" \
            --account-name "$storage_account" \
            --account-key "$access_key" &> /dev/null || true
        
        print_success "Container ready: $container_name"
    done
    
    print_header "GITHUB SECRETS CONFIGURATION"
    
    print_info "Add the following to GitHub repository secrets:"
    echo "   Settings → Secrets and variables → Actions → New repository secret"
    echo ""
    echo -e "${YELLOW}Name:${NC} ARM_ACCESS_KEY"
    echo -e "${YELLOW}Value:${NC}"
    echo "$access_key"
    echo ""
    
    # Option to auto-add secrets via GitHub CLI
    read -p "Would you like to add this secret to GitHub now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh secret set ARM_ACCESS_KEY --body "$access_key" || print_error "Failed to set secret"
    fi
    
    # Save configuration to file
    print_step "Saving backend configuration..."
    create_backend_config "$rg_name" "$storage_account"
    print_success "Backend configuration saved"
    
    print_header "BACKEND SETUP COMPLETE"
    echo "Next steps:"
    echo "  1. Review the terraform backend configuration"
    echo "  2. Update your .github/workflows files with your platform repo details"
    echo "  3. Configure other required Azure secrets (AZURE_CLIENT_ID, etc.)"
    echo "  4. Test with: terraform init"
}

create_backend_config() {
    local rg_name=$1
    local storage_account=$2
    
    cat > backend.tf << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$rg_name"
    storage_account_name = "$storage_account"
    container_name       = "\${var.environment}-state"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
EOF
    
    print_success "Created backend.tf"
}

################################################################################
# VALIDATION-ONLY MODE
################################################################################

validate_setup() {
    print_header "VALIDATING SETUP"
    
    validate_prerequisites || return 1
    validate_azure_login || return 1
    validate_github_login || return 1
    validate_repo_structure || return 1
    
    print_header "VALIDATION COMPLETE"
    print_success "All checks passed! Your repository is ready for deployment."
}

################################################################################
# MAIN
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --help)
                cat << EOF
GitHub Actions Platform - Application Repository Setup Script

USAGE:
    bash setup-app-repo.sh [OPTIONS]

OPTIONS:
    --validate-only     Only validate prerequisites (don't set up backend)
    --help             Show this help message

EXAMPLES:
    # Full setup
    bash setup-app-repo.sh
    
    # Validate only
    bash setup-app-repo.sh --validate-only

EOF
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    print_header "GITHUB ACTIONS PLATFORM - APPLICATION SETUP"
    
    if [ "$VALIDATE_ONLY" = true ]; then
        validate_setup
    else
        validate_prerequisites || exit 1
        validate_azure_login || exit 1
        validate_github_login || exit 1
        validate_repo_structure
        
        read -p "Continue with backend setup? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            setup_azure_backend
        else
            print_info "Setup cancelled"
        fi
    fi
}

# Run main function
main "$@"
