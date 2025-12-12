variable "vault_addr" {
  description = "The URL of the Vault server (e.g., http://192.168.X.X:8200)."
  type        = string
}

variable "vault_token" {
  description = "Privileged token to configure Vault. MUST be passed via environment variable (TF_VAR_vault_token)."
  type        = string
  sensitive   = true
}

variable "policies" {
  description = "Map of policies to provision. Key = Policy Name, Value = Path to local HCL file."
  type        = map(string)
  default = {
    "admin-policy" = "policies/admin-policy.hcl"
    "app-readonly" = "policies/app-readonly.hcl"
  }
}

variable "app_roles" {
  description = "Configuration for Machine Users (AppRoles) and their attached policies."
  type = map(object({
    token_ttl = number
    policies  = list(string)
  }))
  default = {
    "github-actions-runner" = {
      token_ttl = 3600
      policies  = ["app-readonly"]
    }
    "terraform-admin-agent" = {
      token_ttl = 7200
      policies  = ["admin-policy"]
    }
  }
}