# ------------------------------------------------------------------------------
# ☁️ TERRAFORM CONFIGURATION
# ------------------------------------------------------------------------------
terraform {
  required_providers {
    # Secret Management (On-Premise / Edge)
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20.0"
    }
    # Code & CI/CD Management (Cloud)
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    # Utility for generating strong passwords (Secret Zero)
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 🔌 PROVIDER CONFIGURATIONS
# ------------------------------------------------------------------------------

# 1. Vault Connection (Targeting Synology NAS)
provider "vault" {
  address = var.vault_addr
  token   = var.vault_token

  # ⚠️ Security Note: Required for local Synology setups with self-signed certificates.
  # In a production environment with valid certs, this should be false.
  skip_tls_verify = true
}

# 2. GitHub Connection (Targeting Cloud)
provider "github" {
  owner = "soltani-a"
  # The token is automatically read from the 'GITHUB_TOKEN' environment variable.
}