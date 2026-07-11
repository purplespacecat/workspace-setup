<#
.SYNOPSIS
    Restore your PC quickly by installing essential applications, enabling WSL/Ubuntu, updating drivers, installing Visual C++ libraries,
    and ensuring non‑default Microsoft Store apps are installed.

.DESCRIPTION
    This script does the following:
      • Verifies you’re running as Administrator.
      • Installs Chocolatey (if missing) and checks that winget is available.
      • Enables WSL and Virtual Machine Platform.
      • Installs Ubuntu for WSL via winget.
      • Installs basic apps via winget:
          - Google Chrome
          - Visual Studio Code
          - Obsidian
          - Steam
          - Telegram Desktop
      • Installs Surfshark VPN and Visual C++ Redistributable via Chocolatey.
      • Installs additional Chocolatey packages.
      • Attempts to update AMD drivers and install MS Office Home.
      • Checks a predefined list of non‑default Microsoft Store apps (apps that aren’t installed by default on Windows 11)
        and, if missing, attempts to install them via winget.

    **NOTE:** Some apps (such as MS Office Home or AMD drivers) might not be available via winget/choco.
    In those cases, the script will output a message so you can complete those installations manually.

    Modify the `$msAppsToInstall` hashtable as needed. The keys should match the “Name” value (as seen via
    `Get-AppxPackage -AllUsers`), and the values should be the corresponding winget IDs.

.NOTES
    Run this script as Administrator.
#>

# --- Ensure script is run as Administrator ---
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error "This script must be run as Administrator. Exiting..."
    exit 1
}

# --- Helpers ---
# winget/choco are native executables: they never throw PowerShell terminating
# errors on failure, so try/catch around them is dead code — check $LASTEXITCODE.
function Install-WingetApp {
    param([string]$Id)
    winget install -e --id $Id -h --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install $Id via winget (exit code $LASTEXITCODE). Install it manually."
    }
}

function Install-ChocoPackage {
    param([string]$Name)
    choco install $Name -y
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed to install $Name via Chocolatey (exit code $LASTEXITCODE)."
    }
}

# --- Check for Chocolatey ---
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Chocolatey not found. Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Output "Chocolatey is already installed."
}

# --- Check for winget ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "Winget not found. Please install winget from the Microsoft Store and re-run the script."
    # Depending on your needs you may choose to exit.
    # exit 1
} else {
    Write-Output "Winget is available."
}

# --- Enable WSL and Virtual Machine Platform features ---
Write-Output "Enabling Windows Subsystem for Linux and Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# --- Install Ubuntu via winget ---
Write-Output "Installing Ubuntu for WSL..."
Install-WingetApp Canonical.Ubuntu

# --- Install basic applications using winget ---
Write-Output "Installing basic applications via winget..."
$wingetApps = @(
    "Google.Chrome",
    "Microsoft.VisualStudioCode",
    "Obsidian.Obsidian",
    "Valve.Steam",
    "Telegram.TelegramDesktop"
)
foreach ($app in $wingetApps) {
    Install-WingetApp $app
}

# --- Install Surfshark VPN via Chocolatey ---
Write-Output "Installing Surfshark VPN via Chocolatey..."
Install-ChocoPackage surfshark-vpn

# --- Install Visual C++ Redistributable ---
# vcredist140 is the unified 2015-2022 redistributable (supersedes vcredist2019).
Write-Output "Installing Visual C++ Redistributable (2015-2022) via Chocolatey..."
Install-ChocoPackage vcredist140

# --- Install additional Chocolatey packages ---
Write-Output "Installing additional Chocolatey packages..."
$chocoPackages = @(
    "chocolatey-compatibility.extension",
    "chocolatey-core.extension",
    "chocolatey-dotnetfx.extension",
    "dotnetfx",
    "Everything",
    "everythingtoolbar",
    "KB2919355",
    "KB2919442",
    "starship",
    "starship.install"
)

foreach ($pkg in $chocoPackages) {
    Install-ChocoPackage $pkg
}

# --- Update AMD Drivers ---
Write-Output "Attempting to update AMD drivers via winget..."
# Replace the package ID below with the correct one if necessary.
Install-WingetApp AMD.RadeonSoftware

# --- Attempt to install MS Office Home ---
Write-Output "Attempting to install MS Office Home..."
# MS Office Home/Student is often not available as an automated install via winget/choco.
Install-WingetApp Microsoft.Office.Home

# --- Ensure non-default Microsoft Store apps are installed ---
Write-Output "Ensuring non-default Microsoft Store apps are installed..."

# Define a hashtable of non-default MS apps.
# Keys: the app 'Name' as it appears from Get-AppxPackage.
# Values: corresponding winget IDs (adjust as needed).
$msAppsToInstall = @{
    "OpenAI.ChatGPT-Desktop"           = "OpenAI.ChatGPT-Desktop"
    "Microsoft.MicrosoftOfficeHub"       = "Microsoft.MicrosoftOfficeHub"
    # New Teams: Appx name is MSTeams, winget ID Microsoft.Teams (classic
    # "MicrosoftTeams" is retired)
    "MSTeams"                            = "Microsoft.Teams"
    "5319275A.WhatsAppDesktop"           = "5319275A.WhatsAppDesktop"
    "Microsoft.OutlookForWindows"        = "Microsoft.OutlookForWindows"
    "Microsoft.PowerAutomateDesktop"     = "Microsoft.PowerAutomateDesktop"
    "Microsoft.WindowsTerminal"          = "Microsoft.WindowsTerminal"
    "SpotifyAB.SpotifyMusic"             = "SpotifyAB.SpotifyMusic"
    "40174MouriNaruto.NanaZip"            = "40174MouriNaruto.NanaZip"
    "34791E63.CanonInkjetSmartConnect"    = "34791E63.CanonInkjetSmartConnect"
    "21676OptimiliaStudios.AquileReader"   = "21676OptimiliaStudios.AquileReader"
    "B9ECED6F.ASUSPCAssistant"            = "B9ECED6F.ASUSPCAssistant"
}

# Retrieve the names of currently installed Microsoft Store apps
$installedMSApps = (Get-AppxPackage -AllUsers | Select-Object -ExpandProperty Name) | ForEach-Object { $_.Trim() }

foreach ($app in $msAppsToInstall.Keys) {
    if ($installedMSApps -contains $app) {
        Write-Output "$app is already installed."
    } else {
        Write-Output "$app is not installed. Attempting installation via winget..."
        # $(...) is required: bare "$hash[$key]" in an argument expands the hash
        # to its type name and appends "[key]" literally.
        Install-WingetApp $($msAppsToInstall[$app])
    }
}

Write-Output "Installation process complete. Note that some changes (like enabling WSL) may require a system restart."
