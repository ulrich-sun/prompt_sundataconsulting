# DevSecOps Tools Installer - Ubuntu

This Bash script checks and installs essential DevSecOps tools on Ubuntu Linux.  
It supports Git, VS Code, VirtualBox, Vagrant, Docker, Kubectl, Terraform, and selected VSCode extensions.

## Features
- Checks if required tools are already installed.
- Installs missing tools automatically using apt, snap, or official scripts.
- Installs VS Code extensions automatically.
- Provides instructions if a tool cannot be installed automatically.
- Does not overwrite existing installations.

## Supported Tools
- Git
- VS Code
- VirtualBox
- Vagrant
- Docker
- Kubectl

## VS Code Extensions
- GitLens
- YAML
- Docker
- Kubernetes
- Snyk
- SonarLint
- Terraform

## Usage
1. Make the script executable:
```bash
chmod +x install_devsecops_tools.sh
