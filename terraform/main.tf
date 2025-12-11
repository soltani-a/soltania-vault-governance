# ==============================================================================
# 1. VAULT INFRASTRUCTURE: Secret Engine
# ==============================================================================
# Enable Key-Value v2 Secret Engine
resource "vault_mount" "kvv2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine for Soltania Apps"
}

# ==============================================================================
# 2. SECRET ZERO: Dynamic Data Generation
# ==============================================================================
# Generate a cryptographically strong password.
# No human knows this value; it exists only in Terraform state and Vault.
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ==============================================================================
# 3. VAULT STORAGE: App Configuration
# ==============================================================================
# Store the generated config in Vault for audit and backup purposes
resource "vault_kv_secret_v2" "test_app" {
  mount               = vault_mount.kvv2.path
  name                = "test-app/config"
  cas                 = 1 # Check-and-Set: Prevents accidental overwrites
  delete_all_versions = true

  data_json = jsonencode({
    "DB_HOST"     = "postgres.internal.soltania.local",
    "DB_USER"     = "admin_user",
    "DB_PASSWORD" = random_password.db_password.result, # Injected from Random provider
    "API_KEY"     = "sk_live_123456_demo_key_vitrine"
  })

  # Metadata to track ownership without exposing data
  custom_metadata {
    max_versions = 5
    data = {
      owner   = "soltani-a",
      purpose = "showcase-demo"
    }
  }
}

# ==============================================================================
# 4. THE BRIDGE: Sync to GitHub Actions
# ==============================================================================
# Inject the secret directly into the GitHub repository for CI/CD usage.

resource "github_actions_secret" "sync_db_password" {
  repository      = "soltania-vault-governance"
  secret_name     = "VAULT_DEMO_DB_PASSWORD"
  plaintext_value = jsondecode(vault_kv_secret_v2.test_app.data_json)["DB_PASSWORD"]
}

resource "github_actions_secret" "sync_api_key" {
  repository      = "soltania-vault-governance"
  secret_name     = "VAULT_DEMO_API_KEY"
  plaintext_value = jsondecode(vault_kv_secret_v2.test_app.data_json)["API_KEY"]
}

# ==============================================================================
# 5. GOVERNANCE: Policies & Authentication
# ==============================================================================

# Dynamic Policy Creation (Iterates over variables)
resource "vault_policy" "policies" {
  for_each = var.policies

  name   = each.key
  policy = file("${path.module}/${each.value}")
}

# Enable AppRole Auth Method (Machine-to-Machine)
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "24h"
  }
}

# Create Roles and link them to Policies
resource "vault_approle_auth_backend_role" "roles" {
  for_each = var.app_roles

  backend        = vault_auth_backend.approle.path
  role_name      = each.key
  token_policies = each.value.policies
  token_ttl      = each.value.token_ttl

  # Ensure policies are created before assigning them to roles
  depends_on = [vault_policy.policies]
}