# 🔐 Soltania SecOps: Vault Configuration as Code

[![Vault](https://img.shields.io/badge/HashiCorp-Vault-gray?logo=vault&style=flat-square)](https://www.vaultproject.io/)
[![Terraform](https://img.shields.io/badge/Terraform-Managed-purple?logo=terraform&style=flat-square)](https://www.terraform.io/)
[![GitHub Actions](https://img.shields.io/badge/Integration-GitHub_Actions-2088FF?logo=github-actions&style=flat-square)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)

**Centralized Identity & Secret Management Governance.**

This repository serves as the **Control Plane** for a HashiCorp Vault instance hosted on a private Edge Infrastructure (Synology NAS). It enforces **Least Privilege Principles** and **Secret Zero** methodology by managing policies, authentication methods, and dynamic secrets exclusively via Infrastructure as Code (IaC).

---

## 🏛️ Architecture & Workflow

This project acts as a secure bridge between **On-Premise Infrastructure** and **Cloud CI/CD**.

```mermaid
flowchart TD
    subgraph "Local Control Plane (Terraform)"
        TF[🏗️ Terraform]
        Vars[📄 Variables]
    end

    subgraph "Edge Infrastructure (Synology NAS)"
        Vault[🔐 HashiCorp Vault]
        KV[📦 KVv2 Secrets]
        Auth[🛡️ AppRole Auth]
        Policy[📜 ACL Policies]
    end

    subgraph "Cloud Ecosystem (GitHub)"
        GH_Repo[📂 Target Repository]
        GH_Secret[🔑 Action Secrets]
    end

    TF -->|1. Configure & Provision| Vault
    TF -->|2. Generate Dynamic Secret| Vault
    Vault -.->|3. Store Audit Record| KV
    TF -->|4. Secure Injection| GH_Secret
    GH_Secret -.->|5. Consumed by| GH_Repo
````

-----

## 🔥 Key Capabilities

  * **Configuration as Code (CaC):** No manual UI clicks. Policies, Roles, and Engines are defined in HCL.
  * **Variable-Driven Architecture:** Advanced Terraform structures (Maps, Objects) allow adding new AppRoles or Policies simply by updating `variables.tf`, keeping the logic code (`main.tf`) untouched.
  * **The "Secret Zero" Implementation:**
      * Passwords are generated dynamically by Terraform (`random_password`).
      * They are stored in Vault for audit/backup.
      * They are synced to GitHub Actions for usage.
      * *Result:* No human ever knows the production password.
  * **Hybrid Cloud Bridging:** Connects a private Vault (Behind Firewall) to public GitHub Repositories securely during the configuration phase.

-----

## 📂 Project Structure

A clean separation of concerns between Provider configuration, Logic, and Data.

```text
.
├── policies/                 # 📜 Vault ACL Policies (HCL)
│   ├── admin-policy.hcl
│   └── app-readonly.hcl
├── main.tf                   # ⚙️ Resources (KV, Secrets, Sync)
├── provider.tf               # 🔌 Providers (Vault, GitHub, Random)
├── variables.tf              # 📥 Input definitions
├── terraform.tfvars.example  # 📄 Example configuration
└── README.md                 # 📖 Documentation
```

-----

## 🚀 Usage Guide

### 1\. Prerequisites

  * Terraform \>= 1.5
  * Access to the Vault API (Admin Token)
  * GitHub Personal Access Token (PAT) with `repo` scope.

### 2\. Environment Setup

**Security Warning:** Never commit secrets to Git. Use Environment Variables.

```bash
# Vault Connection (Edge/Synology)
export TF_VAR_vault_addr="[http://192.168.](http://192.168.)X.X:8200"
export TF_VAR_vault_token="hvs.your_admin_token"

# GitHub Connection (Cloud)
export GITHUB_TOKEN="ghp_your_github_pat"
```

### 3\. Deployment

Initialize the backend and apply the configuration.

```bash
# Download plugins
terraform init

# Preview changes (Dry Run)
terraform plan

# Apply configuration
terraform apply
```

-----

## 🧪 Showcase Scenario: The "Secret Bridge"

This repository demonstrates a real-world use case implemented in `main.tf`:

1.  **Generation:** Terraform creates a 24-char cryptographically strong password.
2.  **Storage:** The secret is written to Vault (Path: `secret/data/test-app/config`).
3.  **Sync:** The secret is automatically pushed to this GitHub repository as a Secret (`VAULT_DEMO_DB_PASSWORD`).

This allows CI/CD pipelines to use secrets stored in a private Vault without requiring direct network access to the NAS during the pipeline run.

-----

## 🛠️ Adding a New Machine User (AppRole)

To onboard a new CI/CD runner, simply add it to `variables.tf`.

```hcl
app_roles = {
  "new-jenkins-node" = {
    token_ttl = 3600
    policies  = ["app-readonly", "jenkins-specific"]
  }
}
```

-----

## 📜 License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).