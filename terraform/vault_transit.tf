# ==============================================================================
# 🔐 TRANSIT: ENCRYPTION AS A SERVICE (CORRECTED)
# ==============================================================================

locals {
  # Define the message locally to ensure consistency
  transit_plaintext = "Vault is also an ideal solution for Encryption as a Service"
}

# 1. Enable Transit engine
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Encryption as a Service (EaaS) endpoint"
}

# 2. Create a named encryption key
resource "vault_transit_secret_backend_key" "app_key" {
  backend          = vault_mount.transit.path
  name             = "soltania-key"
  deletion_allowed = true
}

# 3. Encrypt a plaintext string using Vault
# FIX: Added explicit dependency to wait for key creation
data "vault_transit_encrypt" "secret_message" {
  backend   = vault_mount.transit.path
  key       = vault_transit_secret_backend_key.app_key.name
  plaintext = base64encode(local.transit_plaintext)

  # IMPORTANT: Forces the read to happen only after the key resource is created
  depends_on = [vault_transit_secret_backend_key.app_key]
}

# --- GitHub Sync: Variable (Ciphertext) ---
resource "github_actions_variable" "sync_encrypted_message" {
  repository    = "soltania-vault-governance"
  variable_name = "VAULT_TRANSIT_CIPHERTEXT"
  value         = data.vault_transit_encrypt.secret_message.ciphertext
}

# --- GitHub Sync: Variable (Plaintext) ---
resource "github_actions_variable" "sync_plaintext_message" {
  repository    = "soltania-vault-governance"
  variable_name = "VAULT_TRANSIT_PLAINTEXT"
  value         = local.transit_plaintext
}