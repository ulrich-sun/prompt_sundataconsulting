# DevSecOps Tools Installer - Windows

This PowerShell script checks and installs essential DevSecOps tools on Windows.  
It supports VS Code, VirtualBox, Vagrant, VMware, Git Bash, MobaXterm, and selected VSCode extensions.

## Features
- Checks if required tools are already installed.
- Installs missing tools automatically using Winget or Chocolatey.
- Installs VS Code extensions automatically.
- Opens official download pages if automatic installation fails.
- Ensures specific versions for stability.
- Does not overwrite existing installations.

## Supported Tools
- VS Code
- VirtualBox
- Vagrant
- VMware Workstation Player
- Git Bash
- MobaXterm

## VS Code Extensions
- GitLens
- YAML
- Docker
- Kubernetes
- Snyk
- SonarLint
- Terraform

## Usage
1. Double-click `InstallDevSecOpsTools.bat` or run the PowerShell script directly.
2. Confirm installation when prompted.
3. Wait for the script to complete.

## Notes
- Administrator privileges are required for some tools.
