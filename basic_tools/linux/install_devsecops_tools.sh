#!/bin/bash

# =======================================
# DevSecOps Tools Checker & Installer - Ubuntu
# =======================================

# Liste des programmes et versions
declare -A tools
tools=(
  ["git"]="2.41"
  ["code"]="1.91.0"
  ["vagrant"]="2.4.0"
  ["virtualbox"]="7.0"
  ["docker"]="24.0"
  ["kubectl"]="1.29"
  ["mobaXterm"]="non applicable"
)

# Extensions VSCode a verifier
extensions=(
  "eamodio.gitlens"
  "redhat.vscode-yaml"
  "ms-azuretools.vscode-docker"
  "ms-kubernetes-tools.vscode-kubernetes-tools"
  "snyk.snyk-vulnerability-scanner"
  "sonarsource.sonarlint-vscode"
  "hashicorp.terraform"
)

# Fonction pour verifier si programme existe
check_program() {
  command -v "$1" >/dev/null 2>&1
}

# Outils manquants
missing_tools=()
for tool in "${!tools[@]}"; do
  if check_program "$tool"; then
    echo "$tool : installe"
  else
    echo "$tool : manquant"
    missing_tools+=("$tool")
  fi
done

# Extensions VSCode manquantes
missing_extensions=()
for ext in "${extensions[@]}"; do
  if code --list-extensions | grep -q "$ext"; then
    echo "Extension VSCode $ext : installee"
  else
    echo "Extension VSCode $ext : manquante"
    missing_extensions+=("$ext")
  fi
done

# Si tout est present
if [ ${#missing_tools[@]} -eq 0 ] && [ ${#missing_extensions[@]} -eq 0 ]; then
  echo "Tous les outils et extensions sont deja installes."
  exit 0
fi

# Afficher manquants
echo
if [ ${#missing_tools[@]} -gt 0 ]; then
  echo "Programmes manquants : ${missing_tools[*]}"
fi
if [ ${#missing_extensions[@]} -gt 0 ]; then
  echo "Extensions VSCode manquantes : ${missing_extensions[*]}"
fi

read -p "Voulez-vous lancer l'installation automatique ? (O/N) " response
if [[ "$response" != "O" && "$response" != "o" ]]; then
  echo "Installation annulee."
  exit 0
fi

# Installer outils
for tool in "${missing_tools[@]}"; do
  echo
  echo "Installation : $tool version ${tools[$tool]}"

  case $tool in
    "git")
      sudo apt update
      sudo apt install -y git
      ;;
    "code")
      if ! command -v code >/dev/null 2>&1; then
        sudo snap install --classic code --channel=1.91/stable
      fi
      ;;
    "vagrant")
      sudo apt update
      sudo apt install -y vagrant
      ;;
    "virtualbox")
      sudo apt update
      sudo apt install -y virtualbox
      ;;
    "docker")
      sudo apt update
      sudo apt install -y docker.io docker-compose
      sudo systemctl enable docker
      sudo systemctl start docker
      ;;
    "kubectl")
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      ;;
    *)
      echo "Installation automatique non disponible pour $tool. Veuillez consulter le site officiel."
      ;;
  esac
done

# Installer extensions VSCode
for ext in "${missing_extensions[@]}"; do
  echo "Installation VSCode extension : $ext"
  code --install-extension "$ext"
done

echo "Installation terminee."
