#!/bin/bash
set -euo pipefail

# Définition de la racine du projet
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Initialisation de la gouvernance GitHub dans $PROJECT_ROOT..."

# 1. Création des dossiers
mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"
echo "✅ Dossier .github/ISSUE_TEMPLATE créé."

# 2. Création du Template de Pull Request
cat <<EOF > "$PROJECT_ROOT/.github/PULL_REQUEST_TEMPLATE.md"
## 📝 Description
Briefly describe the changes introduced by this PR.

## 🎯 Type of change
- [ ] Bug fix
- [ ] New feature (non-breaking change)
- [ ] Refactoring (no functional change, no api change)
- [ ] Documentation update

## ✅ Checklist
- [ ] I have run \`./scripts/tf_wrapper.sh fmt\` locally.
- [ ] My code follows the style guidelines of this project.
- [ ] I have updated the documentation accordingly.
- [ ] I have verified the Terraform Plan output.
EOF
echo "✅ PULL_REQUEST_TEMPLATE.md généré."

# 3. Création du Template Bug Report
cat <<EOF > "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/bug_report.md"
---
name: Bug Report
about: Create a report to help us improve the IaC logic
title: "[BUG] "
labels: bug, terraform
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Edit \`variable.tf\` with...
2. Run script \`./scripts/tf_wrapper.sh plan\`
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots/Logs**
If applicable, add logs or screenshots.
EOF
echo "✅ ISSUE_TEMPLATE/bug_report.md généré."

# 4. Création du Template Feature Request
cat <<EOF > "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/feature_request.md"
---
name: Feature Request
about: Suggest an idea for this project
title: "[FEAT] "
labels: enhancement
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.
EOF
echo "✅ ISSUE_TEMPLATE/feature_request.md généré."

echo "🎉 Gouvernance GitHub installée avec succès !"