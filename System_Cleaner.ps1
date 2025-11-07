<#
    .SYNOPSIS
        Performs a system cleanup routine by deleting temporary files,
        cache data, and running DISM component cleanup.

    .DESCRIPTION
        This script checks for administrator rights and then performs
        four main cleanup actions:
        1. User Temporary Files (%TEMP%)
        2. System Temporary Files (C:\Windows\Temp)
        3. Windows Prefetch Cache (C:\Windows\Prefetch\*.pf)
        4. DISM Component Store Cleanup (Windows Update cache)

    .NOTES
        Run this script as Administrator for a complete cleanup.
        Requires PowerShell 3.0 or higher.
#>

# =========================================================
# CONFIGURATION
# =========================================================
$CleanupLocations = @(
    @{ Name = "User Temporary Files"; Path = "$env:TEMP\*"; Action = "Delete" }
    @{ Name = "System Temporary Files"; Path = "C:\Windows\Temp\*"; Action = "Delete" }
    @{ Name = "Prefetch Cache (.pf files)"; Path = "C:\Windows\Prefetch\*.pf"; Action = "Delete" }
)

$TotalSteps = $CleanupLocations.Count + 1 # +1 for DISM step

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
        Write-Host "WARNING: Not running as Administrator." -ForegroundColor Red
        Write-Host "This script should be run as Administrator for a complete cleanup." -ForegroundColor Yellow
        Write-Host "System Temp and Prefetch cleaning will likely fail without it." -ForegroundColor Yellow
        Write-Host "=========================================================" -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Cleanup-Path
{
    param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    try {
        # Get all files and folders in the path. -ErrorAction SilentlyContinue handles access denied errors gracefully.
        $Items = Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue

        if ($Items.Count -gt 0) {
            # Use Remove-Item with -Recurse and -Force to delete contents
            $Items | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        }

        # Verify if the folder is empty or items were removed
        $RemainingItems = Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue

        if ($RemainingItems.Count -eq 0) {
            Write-Host "✅ $Name cleaned successfully." -ForegroundColor Green
        } else {
            Write-Host "⚠️ $Name cleaned, but some files remain (possibly in use)." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ An error occurred during $Name cleanup. $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-CleanupRoutine
{
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "          STARTING SYSTEM CLEANUP ROUTINE" -ForegroundColor White
    Write-Host "=========================================================" -ForegroundColor Cyan

    # Check for admin rights
    $IsAdmin = Check-Admin

    $StepNumber = 1

    # --- 1-3. Clean Temp Files and Prefetch ---
    foreach ($Location in $CleanupLocations) {
        Write-Host ""
        Write-Host "--- [$StepNumber/$TotalSteps] Cleaning $($Location.Name)... ---" -ForegroundColor Cyan
        Cleanup-Path -Name $Location.Name -Path $Location.Path
        $StepNumber++
    }

    # --- 4. Run DISM Component Cleanup ---
    Write-Host ""
    Write-Host "--- [$StepNumber/$TotalSteps] Starting DISM Component Cleanup (Windows Update Caches)... ---" -ForegroundColor Cyan

    if ($IsAdmin) {
        try {
            # Use Dism.exe for component cleanup
            # /StartComponentCleanup is the safest cleanup option.
            Start-Process -FilePath "Dism" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -Wait -NoNewWindow
            Write-Host "✅ DISM Component Cleanup finished." -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error executing DISM. $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "ℹ️ Skipping DISM cleanup. Requires Administrator privileges." -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Cyan
    Write-Host "          UNUSED FILE CLEANUP COMPLETE!" -ForegroundColor Green
    Write-Host "=========================================================" -ForegroundColor Cyan
}

# EXECUTION
Start-CleanupRoutine

Read-Host "Press Enter to exit..."