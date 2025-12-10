# ÔøΩÔøΩ Soltania SecOps: Vault Configuration as Code

[![Vault](https://img.shields.io/badge/HashiCorp-Vault-gray?logo=vault)](https://www.vaultproject.io/)
[![Terraform](https://img.shields.io/badge/Terraform-Managed-purple?logo=terraform)](https://www.terraform.io/)
[![Security](https://img.shields.io/badge/Security-AppRole-red)]()

**Centralized Identity & Secret Management Governance.**

This repository manages the configuration of a **HashiCorp Vault** instance hosted on a private Synology NAS infrastructure. It enforces **Least Privilege Principles** by defining policies, authentication methods, and roles exclusively via Infrastructure as Code (IaC).

## ÌæØ Architecture Focus: Variable-Driven Deployment

Unlike static configurations, this project uses advanced Terraform structures (Maps, Objects, Loops) to dynamically provision access.

### Adding a new Machine User (AppRole)
To add a new CI/CD runner access, simply update the `variables.tf` structure. No code change required in `main.tf`.

```hcl
app_roles = {
  "new-jenkins-node" = {
    token_ttl = 3600
    policies  = ["readonly", "jenkins-secrets"]
  }
}
```

## Ìª†Ô∏è Tech Stack
* **HashiCorp Vault:** Secret Management Engine.
* **Terraform:** State management and provisioning.
* **HCL:** Policy definition.

## Ì∫Ä Usage

### 1. Define Credentials
Export your Vault Token (Root or Admin) in your shell. **Never commit this.**

```bash
export TF_VAR_vault_addr="http://192.168.X.X:8200"
export TF_VAR_vault_token="hvs.your_admin_token"
```

### 2. Apply Configuration
```bash
terraform init
terraform plan
terraform apply
```
