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
try {
    winget install -e --id=Canonical.Ubuntu -h
} catch {
    Write-Output "Failed to install Ubuntu via winget. Please install it manually from the Microsoft Store."
}

# --- Install basic applications using winget ---
Write-Output "Installing basic applications via winget..."

# Google Chrome
try {
    winget install -e --id=Google.Chrome -h
} catch {
    Write-Output "Failed to install Google Chrome via winget."
}

# Visual Studio Code
try {
    winget install -e --id=Microsoft.VisualStudioCode -h
} catch {
    Write-Output "Failed to install Visual Studio Code via winget."
}

# Obsidian (adjust the package ID if necessary)
try {
    winget install -e --id=Obsidian.Obsidian -h
} catch {
    Write-Output "Failed to install Obsidian via winget."
}

# Steam
try {
    winget install -e --id=Valve.Steam -h
} catch {
    Write-Output "Failed to install Steam via winget."
}

# Telegram Desktop
try {
    winget install -e --id=Telegram.TelegramDesktop -h
} catch {
    Write-Output "Failed to install Telegram Desktop via winget."
}

# --- Install Surfshark VPN via Chocolatey ---
Write-Output "Installing Surfshark VPN via Chocolatey..."
try {
    # Adjust package name if needed (commonly "surfshark-vpn")
    choco install surfshark-vpn -y
} catch {
    Write-Output "Failed to install Surfshark VPN via Chocolatey."
}

# --- Install Visual C++ Redistributable ---
Write-Output "Installing Visual C++ Redistributable (2019) via Chocolatey..."
try {
    choco install vcredist2019 -y
} catch {
    Write-Output "Failed to install Visual C++ Redistributable."
}

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
    try {
        choco install $pkg -y
    } catch {
        Write-Output "Failed to install $pkg via Chocolatey."
    }
}

# --- Update AMD Drivers ---
Write-Output "Attempting to update AMD drivers via winget..."
try {
    # Replace the package ID below with the correct one if necessary.
    winget install -e --id=AMD.RadeonSoftware -h
} catch {
    Write-Output "AMD driver package not available via winget. Please update AMD drivers manually."
}

# --- Attempt to install MS Office Home ---
Write-Output "Attempting to install MS Office Home..."
try {
    # MS Office Home/Student is often not available as an automated install via winget/choco.
    winget install -e --id=Microsoft.Office.Home -h
} catch {
    Write-Output "MS Office Home is not available via winget. Please install it manually."
}

# --- Ensure non-default Microsoft Store apps are installed ---
Write-Output "Ensuring non-default Microsoft Store apps are installed..."

# Define a hashtable of non-default MS apps.
# Keys: the app 'Name' as it appears from Get-AppxPackage.
# Values: corresponding winget IDs (adjust as needed).
$msAppsToInstall = @{
    "OpenAI.ChatGPT-Desktop"           = "OpenAI.ChatGPT-Desktop"
    "Microsoft.MicrosoftOfficeHub"       = "Microsoft.MicrosoftOfficeHub"
    "MicrosoftTeams"                     = "MicrosoftTeams"
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
        try {
            winget install -e --id=$msAppsToInstall[$app] -h
        } catch {
            Write-Output "Failed to install $app via winget. Please install it manually from the Microsoft Store."
        }
    }
}

Write-Output "Installation process complete. Note that some changes (like enabling WSL) may require a system restart."
