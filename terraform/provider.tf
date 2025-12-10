terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20.0"
    }
  }
}

provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
  # Pour un Synology avec certificat auto-signé
  skip_tls_verify = true
}
