# ========================================
# DevSecOps Tools Checker & Installer
# ========================================

# Configuration des programmes et versions
$tools = @(
    @{ Name="VS Code"; Command="code"; Version="1.91.0"; WingetId="Microsoft.VisualStudioCode"; ChocolateyId="vscode"; URL="https://code.visualstudio.com/download" },
    @{ Name="VirtualBox"; Command="VBoxManage"; Version="7.0.14"; WingetId="Oracle.VirtualBox"; ChocolateyId="virtualbox"; URL="https://www.virtualbox.org/wiki/Downloads" },
    @{ Name="Vagrant"; Command="vagrant"; Version="2.4.9"; WingetId="HashiCorp.Vagrant"; ChocolateyId="vagrant"; URL="https://www.vagrantup.com/downloads" },
    #@{ Name="VMware Workstation Player"; Command="vmware"; Version="17.0"; WingetId="VMware.WorkstationPlayer"; ChocolateyId="vmwareworkstationplayer"; URL="https://www.vmware.com/products/workstation-player.html" },
    @{ Name="Git Bash"; Command="bash"; Version="2.41"; WingetId="Git.Git"; ChocolateyId="git"; URL="https://git-scm.com/download/win" },
    @{ Name="MobaXterm"; Command="MobaXterm"; Version="24.4"; WingetId="Mobatek.MobaXterm"; ChocolateyId="mobaxterm"; URL="https://mobaxterm.mobatek.net/download.html" }
)

# Extensions VSCode a verifier
$extensions = @(
    @{ Name="GitLens"; Id="eamodio.gitlens" },
    @{ Name="YAML"; Id="redhat.vscode-yaml" },
    @{ Name="Docker"; Id="ms-azuretools.vscode-docker" },
    @{ Name="Kubernetes"; Id="ms-kubernetes-tools.vscode-kubernetes-tools" },
    @{ Name="Snyk"; Id="snyk.snyk-vulnerability-scanner" },
    @{ Name="SonarLint"; Id="sonarsource.sonarlint-vscode" },
    @{ Name="Terraform"; Id="hashicorp.terraform" }
)

# Fonction pour verifier un programme
function Check-Program {
    param($Tool)
    try {
        $null = Get-Command $Tool.Command -ErrorAction Stop
        Write-Host "$($Tool.Name) : installe"
        return $true
    } catch {
        Write-Host "$($Tool.Name) : manquant"
        return $false
    }
}

# Fonction pour verifier extension VSCode
function Check-VSCodeExtension {
    param($Ext)
    $installed = code --list-extensions | Where-Object { $_ -eq $Ext.Id }
    if ($installed) {
        Write-Host "$($Ext.Name) : installe"
        return $true
    } else {
        Write-Host "$($Ext.Name) : manquant"
        return $false
    }
}

# Liste des outils manquants
$missingTools = @()
foreach ($tool in $tools) {
    if (-not (Check-Program $tool)) { $missingTools += $tool }
}

$missingExtensions = @()
foreach ($ext in $extensions) {
    if (-not (Check-VSCodeExtension $ext)) { $missingExtensions += $ext }
}

# Si tout est present
if ($missingTools.Count -eq 0 -and $missingExtensions.Count -eq 0) {
    Write-Host "`nTous les outils et extensions sont deja installes."
    exit
}

# Demande confirmation
Write-Host "`nLes elements manquants :"
if ($missingTools.Count -gt 0) { Write-Host "`nProgrammes : $($missingTools.Name -join ', ')" }
if ($missingExtensions.Count -gt 0) { Write-Host "`nExtensions VSCode : $($missingExtensions.Name -join ', ')" }

$response = Read-Host "`nVoulez-vous lancer l'installation automatique ? (O/N)"
if ($response -ne "O" -and $response -ne "o") { Write-Host "Installation annulee."; exit }

# Installer les programmes via winget ou chocolatey
foreach ($tool in $missingTools) {
    Write-Host "`nInstallation : $($tool.Name) version $($tool.Version)"
    $installed = $false

    # Verifie si winget existe
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        try {
            winget install --id $tool.WingetId --version $tool.Version --accept-package-agreements --accept-source-agreements -e
            $installed = $true
        } catch { $installed = $false }
    }

    # Si pas installe, essaye Chocolatey
    if (-not $installed -and Get-Command choco -ErrorAction SilentlyContinue) {
        try {
            choco install $tool.ChocolateyId --version $tool.Version -y
            $installed = $true
        } catch { $installed = $false }
    }

    # Si toujours pas installe, ouvre le site officiel
    if (-not $installed) {
        Write-Host "Impossible d'installer automatiquement $($tool.Name). Ouverture du site officiel..."
        Start-Process $tool.URL
    }
}

# Installer les extensions VSCode manquantes
foreach ($ext in $missingExtensions) {
    Write-Host "`nInstallation VSCode extension : $($ext.Name)"
    code --install-extension $ext.Id
}

Write-Host "`nInstallation terminee."
pause
