<#
    .SYNOPSIS
        Disables Windows Copilot (BingChat) via Registry modification
        and hides the taskbar icon.

    .DESCRIPTION
        This script performs two key actions:
        1. Sets 'IsCopilotAvailable' to 0 in the Copilot registry path
           to disable the feature.
        2. Sets 'ShowCopilotButton' to 0 to hide the taskbar icon.

    .NOTES
        These changes apply to the current user (HKCU) and require
        restarting the computer or Windows Explorer to take full effect.
#>

# =========================================================
# CONFIGURATION
# =========================================================

# Registry paths and values to modify. HKCU is used since these are user-specific settings.
$RegistryChanges = @(
    @{
        Name = "Disable Copilot Feature";
        Path = "HKCU:\Software\Microsoft\Windows\Shell\Copilot\BingChat";
        ValueName = "IsCopilotAvailable";
        ValueData = 0;
        Type = [Microsoft.Win32.RegistryValueKind]::DWord
    }
    @{
        Name = "Hide Copilot Taskbar Icon";
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced";
        ValueName = "ShowCopilotButton";
        ValueData = 0;
        Type = [Microsoft.Win32.RegistryValueKind]::DWord
    }
)

# =========================================================
# SCRIPT LOGIC
# =========================================================

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "          STARTING COPILOT DISABLER ROUTINE" -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "ℹ️  This script modifies user-specific settings (HKCU)." -ForegroundColor Yellow
Write-Host ""

foreach ($Change in $RegistryChanges) {
    Write-Host "--- $($Change.Name)..." -NoNewline -ForegroundColor Cyan
    
    try {
        # Ensure the registry path exists before trying to set the value
        if (-not (Test-Path $Change.Path)) {
            New-Item -Path $Change.Path -Force | Out-Null
        }

        # Set the registry value using Set-ItemProperty
        Set-ItemProperty -Path $Change.Path `
            -Name $Change.ValueName `
            -Value $Change.ValueData `
            -Type $Change.Type `
            -ErrorAction Stop | Out-Null

        Write-Host " Updated successfully." -ForegroundColor Green

    } catch {
        Write-Host " Failed!" -ForegroundColor Red
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "          COPILOT DISABLER COMPLETE!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "❗ IMPORTANT: You must **restart your computer** or **restart Windows Explorer**" -ForegroundColor Yellow
Write-Host "to see these changes take full effect." -ForegroundColor Yellow

# Pausing the script until the user presses Enter
Read-Host "Press Enter to exit..."