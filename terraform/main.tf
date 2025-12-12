# ==============================================================================
# 🛡️ GOVERNANCE: POLICIES & AUTHENTICATION
# ==============================================================================

# 1. Dynamic Policy Management
# Reads local HCL files and uploads them to Vault.
resource "vault_policy" "policies" {
  for_each = var.policies

  name   = each.key
  policy = file("${path.module}/${each.value}")
}

# 2. Enable AppRole Auth Method
# Standard method for Machine-to-Machine authentication.
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle"

  tune {
    default_lease_ttl = "1h"
    max_lease_ttl     = "24h"
  }
}

# 3. Create Machine Roles
# Defines specific roles linked to policies.
resource "vault_approle_auth_backend_role" "roles" {
  for_each = var.app_roles

  backend        = vault_auth_backend.approle.path
  role_name      = each.key
  token_policies = each.value.policies
  token_ttl      = each.value.token_ttl

  # Ensure policies exist before assigning them
  depends_on = [vault_policy.policies]
}