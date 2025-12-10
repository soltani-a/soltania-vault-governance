#!/bin/bash

# ==============================================================================
# Terraform Automation Wrapper for Slim Soltani - Solutions Architect
# Description: Robust wrapper to init, plan, and apply infrastructure.
# Usage: ./scripts/tf_wrapper.sh [fmt] [init] [plan] [apply] [destroy]
# Example: ./scripts/tf_wrapper.sh fmt init plan apply
# ==============================================================================

# 1. Strict Mode (Fail on error, undefined vars, or pipe failures)
set -euo pipefail

# 2. Constants and Path Definitions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLAN_FILE="tfplan.binary"

# --- AUTO-DÉTECTION DU DOSSIER TERRAFORM ---
# Vérifie si main.tf est dans /terraform, sinon suppose qu'il est à la racine.
if [ -d "$PROJECT_ROOT/terraform" ] && [ -f "$PROJECT_ROOT/terraform/main.tf" ]; then
    TERRAFORM_DIR="$PROJECT_ROOT/terraform"
else
    TERRAFORM_DIR="$PROJECT_ROOT"
fi

# Color Codes for improved readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 3. Utility Functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_dependencies() {
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed or not in the PATH."
        exit 1
    fi
    
    if [ -z "${GITHUB_TOKEN:-}" ]; then
         log_warn "GITHUB_TOKEN variable is not set. Terraform might fail if the provider requires it."
    fi
}

usage() {
    echo "Usage: $0 [command1] [command2] ..."
    echo "Commands:"
    echo "  fmt     : Format Terraform code recursively"
    echo "  init    : Initialize Terraform backend and providers"
    echo "  plan    : Generate an execution plan"
    echo "  apply   : Apply the generated plan"
    echo "  destroy : Destroy the infrastructure"
    echo ""
    echo "Example: $0 fmt init plan apply"
    exit 1
}

# 4. Main Execution Logic
main() {
    # Argument validation
    if [ $# -eq 0 ]; then
        usage
    fi
    
    log_info "Starting Terraform Wrapper..."
    check_dependencies
    
    # Navigate to the Terraform directory ONCE before the loop
    if [ ! -d "$TERRAFORM_DIR" ]; then
        log_error "Terraform directory not found: $TERRAFORM_DIR"
        exit 1
    fi
    
    log_info "Working directory: $TERRAFORM_DIR"
    cd "$TERRAFORM_DIR"

    # --- CHANGEMENT : Boucle sur tous les arguments passés au script ---
    for COMMAND in "$@"; do
        
        echo "" # Saut de ligne pour la lisibilité
        log_info ">>> EXECUTING: ${COMMAND} <<<"

        case "$COMMAND" in
            fmt)
                log_info "Formatting Terraform code..."
                terraform fmt -recursive
                log_success "Formatting complete."
                ;;
                
            init)
                log_info "Initializing backend and providers..."
                terraform init -upgrade
                log_success "Initialization complete."
                ;;
                
            plan)
                log_info "Generating execution plan..."
                # Check formatting before planning
                terraform fmt -check || log_warn "Code is not formatted. Adding 'fmt' to your arguments is recommended."
                
                # On s'assure que l'init est fait (idempotent)
                terraform init -input=false
                terraform plan -out="$PLAN_FILE"
                
                log_success "Plan generated at: $PLAN_FILE"
                ;;
                
            apply)
                log_info "Applying infrastructure changes..."
                
                if [ -f "$PLAN_FILE" ]; then
                    log_info "Applying existing plan file..."
                    terraform apply "$PLAN_FILE"
                    rm -f "$PLAN_FILE" # Cleanup
                else
                    log_warn "No plan file found. Running interactive apply..."
                    terraform apply
                fi
                
                log_success "Deployment completed successfully!"
                ;;
                
            destroy)
                log_warn "WARNING: You are about to DESTROY the infrastructure."
                terraform destroy
                ;;
                
            *)
                log_error "Unknown command: $COMMAND"
                usage
                ;;
        esac
    done
}

# Execute main function with arguments
main "$@"