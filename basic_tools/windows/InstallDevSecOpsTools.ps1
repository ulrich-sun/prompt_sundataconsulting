# ========================================
# DevSecOps Tools Checker & Installer
# ========================================

# ------------------------
# Configuration des outils
# ------------------------
$tools = @(
    @{ Name="VS Code"; Command="code"; Version="1.91.0"; WingetId="Microsoft.VisualStudioCode"; ChocolateyId="vscode"; URL="https://code.visualstudio.com/download" },
    @{ Name="VirtualBox"; Check="VirtualBox"; Version="7.0.14"; WingetId="Oracle.VirtualBox"; ChocolateyId="virtualbox"; URL="https://www.virtualbox.org/wiki/Downloads" },
    @{ Name="Vagrant"; Command="vagrant"; Version="2.4.9"; WingetId="HashiCorp.Vagrant"; ChocolateyId="vagrant"; URL="https://www.vagrantup.com/downloads" },
    @{ Name="Git Bash"; Command="bash"; Version="2.41"; WingetId="Git.Git"; ChocolateyId="git"; URL="https://git-scm.com/download/win" },
    @{ Name="MobaXterm"; Path="C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe"; Version="25.4.0.5418"; WingetId="Mobatek.MobaXterm"; ChocolateyId="mobaxterm"; URL="https://mobaxterm.mobatek.net/download.html" }
)

# ------------------------
# Extensions VSCode
# ------------------------
$extensions = @(
    @{ Name="GitLens"; Id="eamodio.gitlens" },
    @{ Name="YAML"; Id="redhat.vscode-yaml" },
    @{ Name="Docker"; Id="ms-azuretools.vscode-docker" },
    @{ Name="Kubernetes"; Id="ms-kubernetes-tools.vscode-kubernetes-tools" },
    @{ Name="Snyk"; Id="snyk.snyk-vulnerability-scanner" },
    @{ Name="SonarLint"; Id="sonarsource.sonarlint-vscode" },
    @{ Name="Terraform"; Id="hashicorp.terraform" }
)

# ------------------------
# Fonctions de vérification
# ------------------------

function Check-VirtualBox {
    if (Test-Path "HKLM:\SOFTWARE\Oracle\VirtualBox") { return $true }
    if (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Oracle\VirtualBox") { return $true }
    if (Test-Path "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe") { return $true }
    return $false
}

function Check-Program {
    param($Tool)

    # Cas spécifique VirtualBox
    if ($Tool.Check -eq "VirtualBox") {
        if (Check-VirtualBox) {
            Write-Host "VirtualBox : installe"
            return $true
        }
        Write-Host "VirtualBox : manquant"
        return $false
    }

    # Vérification via PATH
    if ($Tool.Command -and (Get-Command $Tool.Command -ErrorAction SilentlyContinue)) {
        Write-Host "$($Tool.Name) : installe"
        return $true
    }

    # Vérification via chemin explicite (GUI tools)
    if ($Tool.Path -and (Test-Path $Tool.Path)) {
        Write-Host "$($Tool.Name) : installe"
        return $true
    }

    Write-Host "$($Tool.Name) : manquant"
    return $false
}

function Check-VSCodeExtension {
    param($Ext)
    if (code --list-extensions | Where-Object { $_ -eq $Ext.Id }) {
        Write-Host "$($Ext.Name) : installe"
        return $true
    }
    Write-Host "$($Ext.Name) : manquant"
    return $false
}

# ------------------------
# Détection des manquants
# ------------------------
$missingTools = @()
foreach ($tool in $tools) {
    if (-not (Check-Program $tool)) {
        $missingTools += $tool
    }
}

$missingExtensions = @()
foreach ($ext in $extensions) {
    if (-not (Check-VSCodeExtension $ext)) {
        $missingExtensions += $ext
    }
}

# ------------------------
# Résumé
# ------------------------
if ($missingTools.Count -eq 0 -and $missingExtensions.Count -eq 0) {
    Write-Host "`nTous les outils et extensions sont deja installes."
    exit
}

Write-Host "`nElements manquants :"
if ($missingTools.Count -gt 0) {
    Write-Host "Programmes : $($missingTools.Name -join ', ')"
}
if ($missingExtensions.Count -gt 0) {
    Write-Host "Extensions VSCode : $($missingExtensions.Name -join ', ')"
}

$response = Read-Host "`nLancer l'installation automatique ? (O/N)"
if ($response -notin @("O","o")) {
    Write-Host "Installation annulee."
    exit
}

# ------------------------
# Installation des outils
# ------------------------
foreach ($tool in $missingTools) {
    Write-Host "`nInstallation : $($tool.Name)"
    $installed = $false

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install --id $tool.WingetId `
                           --version $tool.Version `
                           --accept-package-agreements `
                           --accept-source-agreements `
                           -e
            $installed = $true
        } catch {}
    }

    $chocoAvailable = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $installed -and $chocoAvailable) {
        try {
            choco install $tool.ChocolateyId --version $tool.Version -y
            $installed = $true
        } catch {}
    }

    if (-not $installed) {
        Write-Host "Installation automatique impossible."
        Start-Process $tool.URL
    }
}

# ------------------------
# Installation des extensions VSCode
# ------------------------
foreach ($ext in $missingExtensions) {
    Write-Host "`nInstallation extension VSCode : $($ext.Name)"
    code --install-extension $ext.Id
}

Write-Host "`nInstallation terminee."
pause


