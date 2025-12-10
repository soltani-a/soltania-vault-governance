# Read-only access to secrets
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}

# Deny access to admin paths
path "sys/*" {
  capabilities = ["deny"]
}
