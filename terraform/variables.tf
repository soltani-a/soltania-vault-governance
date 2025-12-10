variable "vault_addr" {
  description = "The URL of the Vault server"
  type        = string
}

variable "vault_token" {
  description = "Privileged token to configure Vault"
  type        = string
  sensitive   = true
}

variable "policies" {
  description = "Map of policies to create. Key = Policy Name, Value = Path to HCL file"
  type        = map(string)
  default = {
    "admin-policy" = "policies/admin-policy.hcl"
    "app-readonly" = "policies/app-readonly.hcl"
  }
}

variable "app_roles" {
  description = "List of AppRoles to create with their attached policies"
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
