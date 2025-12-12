# ==============================================================================
# 📦 KEY-VALUE STORE (V2)
# ==============================================================================

# Enable the KVv2 secret engine at path 'secret/'
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine for Soltania Apps"
}

# --- Secret Zero Generation ---
# Generate a random password so it never exists in plain text config files.
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# --- Vault Storage ---
# Store the generated data in Vault as the Single Source of Truth.
resource "vault_kv_secret_v2" "test_app" {
  mount               = vault_mount.kvv2.path
  name                = "test-app/config"
  cas                 = 1 # Check-and-Set: Prevents accidental overwrites
  delete_all_versions = true

  data_json = jsonencode({
    # Public Configuration (Variables)
    "DB_HOST" = "postgres.internal.soltania.local",
    "DB_USER" = "admin_user",

    # Sensitive Data (Secrets)
    "DB_PASSWORD" = random_password.db_password.result,
    "API_KEY"     = "sk_live_123456_demo_key_vitrine"
  })

  custom_metadata {
    max_versions = 5
    data = {
      owner   = "soltania-a",
      purpose = "showcase-demo"
    }
  }
}

# --- GitHub Sync: Secrets (Encrypted ***) ---
resource "github_actions_secret" "sync_db_password" {
  repository      = "soltania-vault-governance"
  secret_name     = "VAULT_DB_PASSWORD"
  plaintext_value = jsondecode(vault_kv_secret_v2.test_app.data_json)["DB_PASSWORD"]
}

resource "github_actions_secret" "sync_api_key" {
  repository      = "soltania-vault-governance"
  secret_name     = "VAULT_API_KEY"
  plaintext_value = jsondecode(vault_kv_secret_v2.test_app.data_json)["API_KEY"]
}

# --- GitHub Sync: Variables (Visible) ---
resource "github_actions_variable" "sync_db_host" {
  repository    = "soltania-vault-governance"
  variable_name = "APP_DB_HOST"
  value         = jsondecode(vault_kv_secret_v2.test_app.data_json)["DB_HOST"]
}

resource "github_actions_variable" "sync_db_user" {
  repository    = "soltania-vault-governance"
  variable_name = "APP_DB_USER"
  value         = jsondecode(vault_kv_secret_v2.test_app.data_json)["DB_USER"]
}