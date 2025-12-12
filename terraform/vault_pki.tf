# ==============================================================================
# 📜 PKI: CERTIFICATE AUTHORITY
# ==============================================================================

# Enable PKI engine
resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Soltania Internal CA"

  # Set long TTLs for the demo environment
  default_lease_ttl_seconds = 31536000 # 1 year
  max_lease_ttl_seconds     = 31536000
}

# --- Root CA Setup ---
# Generate self-signed Root Certificate
resource "vault_pki_secret_backend_root_cert" "root_ca" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Soltania Root CA"
  ttl         = "31536000s"
  format      = "pem"

  # Private key is generated and stored internally in Vault
  private_key_format = "der"
  key_type           = "rsa"
  key_bits           = 4096
}

# --- Role Definition ---
# Define rules for issuing certificates (allowed domains, subdomains)
resource "vault_pki_secret_backend_role" "server_role" {
  backend          = vault_mount.pki.path
  name             = "soltania-dot-local"
  allow_localhost  = true
  allowed_domains  = ["soltania.local", "internal.local"]
  allow_subdomains = true
  max_ttl          = "72h"
}

# --- Certificate Generation ---
# Request a new certificate for an internal service
resource "vault_pki_secret_backend_cert" "app_cert" {
  backend     = vault_mount.pki.path
  name        = vault_pki_secret_backend_role.server_role.name
  common_name = "api.internal.soltania.local"
  format      = "pem"

  # Ensure Root CA exists before requesting a cert
  depends_on = [vault_pki_secret_backend_root_cert.root_ca]
}

# --- GitHub Sync: SSL Secrets ---
# Certificates are synced as Secrets to avoid cluttering the Variables UI,
# and because the Private Key is highly sensitive.

resource "github_actions_secret" "sync_ssl_cert" {
  repository      = "soltania-vault-governance"
  secret_name     = "SSL_CERTIFICATE_PEM"
  plaintext_value = vault_pki_secret_backend_cert.app_cert.certificate
}

resource "github_actions_secret" "sync_ssl_key" {
  repository      = "soltania-vault-governance"
  secret_name     = "SSL_PRIVATE_KEY_PEM"
  plaintext_value = vault_pki_secret_backend_cert.app_cert.private_key
}

resource "github_actions_secret" "sync_ssl_ca" {
  repository      = "soltania-vault-governance"
  secret_name     = "SSL_CA_BUNDLE"
  plaintext_value = vault_pki_secret_backend_cert.app_cert.issuing_ca
}