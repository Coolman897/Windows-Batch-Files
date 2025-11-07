<#
    .SYNOPSIS
        Disables various Windows privacy and telemetry features via Registry and Service control.

    .DESCRIPTION
        This script performs four main actions:
        1. Disables Windows Telemetry (Data Collection).
        2. Disables the Location Tracking Service (lfsvc).
        3. Disables the Advertising ID for personalized ads.
        4. Disables Web Search integration in the Start Menu/Cortana.

    .NOTES
        Must be run as Administrator due to changes in HKLM and service control.
        A restart of the computer is recommended for all changes to take effect.
#>

# =========================================================
# FUNCTIONS
# =========================================================

function Check-Admin
{
    # Check if the script is running with elevated (Administrator) privileges.
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($id)
    if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "=========================================================" -ForegroundColor Yellow
        Write-Host "FATAL: This script MUST be run as Administrator." -ForegroundColor Red
        Write-Host "Please right-click the file and select 'Run as Administrator'." -ForegroundColor Yellow
        Write-Host "=========================================================" -ForegroundColor Yellow
        exit 1
    }
}

function Set-PrivacyRegistryValue {
    param(
        [string]$Name,
        [string]$Path,
        [string]$ValueName,
        [int]$ValueData,
        [Microsoft.Win32.RegistryValueKind]$Type = [Microsoft.Win32.RegistryValueKind]::DWord
    )

    Write-Host "--- $($Name)..." -NoNewline -ForegroundColor Cyan

    try {
        # Ensure the registry path exists before trying to set the value
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        # Set the registry value
        Set-ItemProperty -Path $Path `
            -Name $ValueName `
            -Value $ValueData `
            -Type $Type `
            -Force `
            -ErrorAction Stop | Out-Null

        Write-Host " Updated successfully." -ForegroundColor Green

    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "❌ Error: Could not set registry value. $($_.Exception.Message)" -ForegroundColor Red
    }
}

# =========================================================
# SCRIPT LOGIC (Requires Administrator)
# =========================================================

# Step 0: Mandatory check for Administrator rights
Check-Admin

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   STARTING WINDOWS PRIVACY AND TELEMETRY DISABLER" -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "ℹ️  The script is running with Administrator rights." -ForegroundColor Green
Write-Host ""

# --- 1. Disable Telemetry and Data Collection ---
Set-PrivacyRegistryValue -Name "[1/4] Disabling Windows Telemetry (HKLM)" `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -ValueName "AllowTelemetry" `
    -ValueData 0

# --- 2. Disable Location Tracking Service (lfsvc) ---
Write-Host ""
Write-Host "--- [2/4] Disabling Windows Location Service (lfsvc)..." -NoNewline -ForegroundColor Cyan

try {
    # Stop the service if it's running
    Stop-Service -Name "lfsvc" -ErrorAction SilentlyContinue | Out-Null

    # Set the service startup type to Disabled
    Set-Service -Name "lfsvc" -StartupType Disabled -ErrorAction Stop | Out-Null
    
    Write-Host " Disabled successfully." -ForegroundColor Green
} catch {
    Write-Host " Failed!" -ForegroundColor Red
    Write-Host "❌ Error: Could not manage service. $($_.Exception.Message)" -ForegroundColor Red
}

# --- 3. Disable Advertising ID (HKCU) ---
Write-Host ""
# For personalized ads based on diagnostic data
Set-PrivacyRegistryValue -Name "[3a/4] Disabling Tailored Experiences (HKCU)" `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" `
    -ValueName "TailoredExperiencesWithDiagnosticDataEnabled" `
    -ValueData 0

# For the generic Advertising ID
Set-PrivacyRegistryValue -Name "[3b/4] Disabling Advertising ID (HKCU)" `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -ValueName "Enabled" `
    -ValueData 0

# --- 4. Disable Cortana/Search Web Integration (HKCU) ---
Write-Host ""
# Prevents web search results in the Start Menu
Set-PrivacyRegistryValue -Name "[4a/4] Disabling Bing Web Search (HKCU)" `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -ValueName "BingSearchEnabled" `
    -ValueData 0

# Hides Cortana entirely/sets consent to minimum
Set-PrivacyRegistryValue -Name "[4b/4] Disabling Cortana Consent (HKCU)" `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
    -ValueName "CortanaConsent" `
    -ValueData 0


Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "          PRIVACY SETTINGS APPLIED!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "❗ IMPORTANT: Please **restart your computer** for all changes to take full effect." -ForegroundColor Yellow

# Pausing the script until the user presses Enter
Read-Host "Press Enter to exit..."