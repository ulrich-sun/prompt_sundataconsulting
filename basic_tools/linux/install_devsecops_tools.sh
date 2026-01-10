#!/bin/bash

# =======================================
# DevSecOps Tools Checker & Installer - Ubuntu (Version Locked)
# =======================================

set -e

# -------------------------
# Versions cibles
# -------------------------
GIT_VERSION="1:2.41.*"
VAGRANT_VERSION="2.4.0"
VIRTUALBOX_VERSION="7.0"
DOCKER_VERSION="5:24.0.*"
KUBECTL_VERSION="v1.29.0"
VSCODE_CHANNEL="1.91/stable"

# -------------------------
# Extensions VSCode
# -------------------------
extensions=(
  "eamodio.gitlens"
  "redhat.vscode-yaml"
  "ms-azuretools.vscode-docker"
  "ms-kubernetes-tools.vscode-kubernetes-tools"
  "snyk.snyk-vulnerability-scanner"
  "sonarsource.sonarlint-vscode"
  "hashicorp.terraform"
)

# -------------------------
# Fonctions utilitaires
# -------------------------
check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

check_pkg_version() {
  dpkg -l | grep -E "^ii\s+$1\s+$2" >/dev/null 2>&1
}

check_virtualbox() {
  check_cmd VBoxManage
}

check_docker() {
  check_cmd docker && systemctl is-active --quiet docker
}

# -------------------------
# Vérification
# -------------------------
missing_tools=()

check_pkg_version git "$GIT_VERSION" || missing_tools+=("git")
check_cmd vagrant || missing_tools+=("vagrant")
check_virtualbox || missing_tools+=("virtualbox")
check_docker || missing_tools+=("docker")
check_cmd kubectl || missing_tools+=("kubectl")
check_cmd code || missing_tools+=("code")

# -------------------------
# Vérification extensions VSCode
# -------------------------
missing_extensions=()
if check_cmd code; then
  for ext in "${extensions[@]}"; do
    code --list-extensions | grep -q "^$ext$" || missing_extensions+=("$ext")
  done
fi

# -------------------------
# Résumé
# -------------------------
if [ ${#missing_tools[@]} -eq 0 ] && [ ${#missing_extensions[@]} -eq 0 ]; then
  echo "Tous les outils et extensions sont installes avec les bonnes versions."
  exit 0
fi

echo
[ ${#missing_tools[@]} -gt 0 ] && echo "Outils a installer : ${missing_tools[*]}"
[ ${#missing_extensions[@]} -gt 0 ] && echo "Extensions VSCode a installer : ${missing_extensions[*]}"

read -p "Lancer l'installation avec versions verrouillees ? (O/N) " r
[[ "$r" != "O" && "$r" != "o" ]] && echo "Installation annulee." && exit 0

# -------------------------
# Installation
# -------------------------
sudo apt update

for tool in "${missing_tools[@]}"; do
  echo
  echo "Installation de $tool"

  case "$tool" in
    git)
      sudo apt install -y git="$GIT_VERSION"
      ;;
    vagrant)
      sudo apt install -y vagrant="$VAGRANT_VERSION"* || {
        echo "Version exacte de Vagrant indisponible via apt."
        exit 1
      }
      ;;
    virtualbox)
      sudo apt install -y "virtualbox-$VIRTUALBOX_VERSION"
      ;;
    docker)
      sudo apt install -y docker.io docker-compose
      sudo systemctl enable --now docker
      ;;
    kubectl)
      curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
      ;;
    code)
      sudo snap install --classic code --channel="$VSCODE_CHANNEL"
      ;;
  esac
done

# -------------------------
# Extensions VSCode
# -------------------------
for ext in "${missing_extensions[@]}"; do
  code --install-extension "$ext"
done

echo
echo "Installation terminee avec versions controlees."
