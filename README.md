# 🔐 Soltania SecOps: Vault Configuration as Code

[](https://www.vaultproject.io/)
[](https://www.terraform.io/)
[](https://www.google.com/search?q=)
[](https://www.google.com/search?q=LICENSE)

**Centralized Identity & Secret Management Governance.**

This repository serves as the **Control Plane** for a HashiCorp Vault instance hosted on a private Edge Infrastructure (Synology NAS). It enforces **Least Privilege Principles** and **Secret Zero** methodology by managing policies, authentication methods, dynamic secrets, encryption keys, and PKI infrastructure exclusively via Infrastructure as Code (IaC).

-----

## 🏛️ Architecture & Workflow

This project acts as a secure bridge between **On-Premise Infrastructure** and **Cloud CI/CD**.

```mermaid
flowchart TD
    subgraph "Local Control Plane (Terraform)"
        TF["🏗️ Terraform"]
        Vars["📄 Variables"]
    end

    subgraph "Edge Infrastructure (Synology NAS)"
        Vault["🔐 HashiCorp Vault"]
        KV["📦 KVv2 Secrets"]
        Transit["🛡️ Transit (EaaS)"]
        PKI["📜 PKI Engine"]
    end

    subgraph "Cloud Ecosystem (GitHub)"
        GH_Repo["📂 Target Repository"]
        GH_Secret["🔑 Action Secrets"]
        GH_Var["📝 Action Variables"]
        Workflow["🤖 CI/CD Workflow"]
    end

    TF -->|1. Configure & Provision| Vault
    TF -->|2. Generate Secrets/Certs/Keys| Vault
    Vault -.->|3. Encryption & Audit| Transit
    
    TF -->|4. Secure Injection (Sensitive)| GH_Secret
    TF -->|5. Secure Injection (Non-Sensitive)| GH_Var
    
    GH_Secret -.->|6. Consumed by| Workflow
    GH_Var -.->|6. Consumed by| Workflow
```

-----

## 🔥 Key Capabilities

  * **Configuration as Code (CaC):** No manual UI clicks. Policies, Roles, and Engines are defined in HCL.
  * **Encryption as a Service (Transit):** Offloads data encryption to Vault. The application never handles encryption keys; it only sends data to be encrypted/decrypted.
  * **Automated PKI:** Generates and rotates internal TLS certificates automatically via Terraform.
  * **The "Secret Zero" Implementation:**
      * Passwords and Keys are generated dynamically.
      * They are synced to GitHub Actions for usage.
      * *Result:* No human ever knows the production secrets.
  * **Hybrid Cloud Bridging:** Connects a private Vault (Behind Firewall) to public GitHub Repositories securely during the configuration phase.

-----

## 📂 Project Structure

A clean separation of concerns between Provider configuration, Logic, and Data.

```text
.
├── .github/
│   └── workflows/
│       └── verify-bridge.yml # 🤖 CI/CD: Verifies secrets are correctly synced
├── policies/                 # 📜 Vault ACL Policies (HCL)
│   ├── admin-policy.hcl
│   └── app-readonly.hcl
├── main.tf                   # ⚙️ Core Logic: KV, Transit, PKI, & GitHub Sync
├── provider.tf               # 🔌 Providers: Vault, GitHub, Random
├── variables.tf              # 📥 Input definitions
├── terraform.tfvars.example  # 📄 Example configuration values
└── README.md                 # 📖 Documentation
```

-----

## 🚀 Usage Guide

### 1\. Prerequisites

  * **Terraform** \>= 1.5
  * **Vault Access:** An active Vault server (Local or Remote) with a token.
  * **GitHub Access:** A Personal Access Token (PAT) with `repo` scope (to write secrets/variables).

### 2\. Environment Variables (Required)

To run this script securely, you **must** set the following environment variables. Do not hardcode these values in `.tf` files.

| Variable | Description | Example |
| :--- | :--- | :--- |
| `TF_VAR_vault_addr` | **Vault URL.** The address of your Vault server. | `http://127.0.0.1:8200` |
| `TF_VAR_vault_token` | **Vault Token.** Must have admin/root privileges to create mounts. | `hvs.ImARootToken...` |
| `GITHUB_TOKEN` | **GitHub PAT.** Required to inject secrets into the repo. | `ghp_SecretToken...` |

**Setup (Linux/Mac):**

```bash
export TF_VAR_vault_addr="http://192.168.1.100:8200"
export TF_VAR_vault_token="hvs.your_admin_token"
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

## 🧪 Showcase Scenarios

This repository demonstrates three real-world use cases implemented in `main.tf`.

### Scenario A: The Secret Bridge (KV)

1.  Terraform generates a random password.
2.  Stores it in **Vault KV**.
3.  Injects it as a **GitHub Secret** (`VAULT_DEMO_DB_PASSWORD`).
4.  *Benefit:* The secret is safe, versioned, and available to CI/CD without hardcoding.

### Scenario B: Encryption as a Service (Transit)

1.  Terraform defines a plaintext message ("Vault is...").
2.  Sends it to **Vault Transit** to be encrypted.
3.  Injects the *Ciphertext* as a **GitHub Variable** (`VAULT_TRANSIT_CIPHERTEXT`).
4.  *Benefit:* Developers can handle encrypted data without managing keys.

### Scenario C: PKI Automation

1.  Terraform requests a new TLS certificate from **Vault PKI**.
2.  Injects the certificate and private key as **GitHub Secrets**.
3.  *Benefit:* Certificates are short-lived and automatically rotated on every `apply`.

-----

## 🤖 CI/CD Workflow (`verify-bridge.yml`)

This repository includes a GitHub Action workflow to verify the bridge integrity.

  * **Trigger:** Push to `main`.
  * **Action:** It attempts to read the injected Secrets and Variables.
  * **Goal:** Prove that Terraform successfully "bridged" the gap between the local NAS and the Cloud.

*Example Output in GitHub Actions:*

```text
Verifying Bridge...
[OK] Database Password found (***)
[OK] Transit Ciphertext found (vault:v1:8nB...)
[OK] TLS Certificate found.
```

-----

## 📜 License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).