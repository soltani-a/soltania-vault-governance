#!/bin/bash

# ==============================================================================
# Git & Terraform Workflow for Slim Soltani
# Description: Formats Terraform code, prompts for a commit message, and pushes.
# Usage: ./scripts/publish.sh
# ==============================================================================

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

main() {
    # 1. Format Terraform Code
    log_info "Step 1/3: Formatting Terraform code..."
    if [ -d "$TERRAFORM_DIR" ]; then
        cd "$TERRAFORM_DIR"
        terraform fmt -recursive
        cd "$PROJECT_ROOT" # Go back to root for git operations
    else
        log_warn "Terraform directory not found. Skipping formatting."
    fi

    # 2. Check for changes
    if [ -z "$(git status --porcelain)" ]; then
        log_success "No changes to commit. Everything is clean."
        exit 0
    fi

    # Show status to the user
    echo -e "\n--- Git Status ---"
    git status -s
    echo -e "------------------\n"

    # 3. Prompt for Commit Message
    log_info "Step 2/3: Preparing to commit."
    read -p "Enter your commit message: " COMMIT_MSG

    if [ -z "$COMMIT_MSG" ]; then
        log_error "Commit message cannot be empty. Aborting."
        exit 1
    fi

    # 4. Add, Commit, Push
    log_info "Step 3/3: Pushing to remote..."
    
    git add .
    git commit -m "$COMMIT_MSG"
    
    # Get current branch name safely
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$CURRENT_BRANCH"

    log_success "Successfully pushed to branch '$CURRENT_BRANCH'!"
}

main "$@"