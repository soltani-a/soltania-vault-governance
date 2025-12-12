# ==============================================================================
# 🔐 TRANSIT: ENCRYPTION AS A SERVICE
# ==============================================================================

# 1. Enable Transit engine for on-the-fly encryption/decryption
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Encryption as a Service (EaaS) endpoint"
}

# 2. Create a named encryption key
# This IS a resource because the key configuration is stored in Vault.
resource "vault_transit_secret_backend_key" "app_key" {
  backend          = vault_mount.transit.path
  name             = "soltania-key"
  deletion_allowed = true
}

# 3. Encrypt a plaintext string using Vault
# ⚠️ FIX: Used 'data' block as 'vault_transit_encrypt' is a Data Source, not a Resource.
data "vault_transit_encrypt" "secret_message" {
  backend   = vault_mount.transit.path
  key       = vault_transit_secret_backend_key.app_key.name
  plaintext = base64encode("The Soltania SecOps architecture is validated!")
}

# --- GitHub Sync: Variable (Ciphertext) ---
# We store the encrypted result as a visible variable.
resource "github_actions_variable" "sync_encrypted_message" {
  repository    = "soltania-vault-governance"
  variable_name = "VAULT_TRANSIT_CIPHERTEXT"

  # ⚠️ FIX: Reference the data source correctly
  value = data.vault_transit_encrypt.secret_message.ciphertext
}