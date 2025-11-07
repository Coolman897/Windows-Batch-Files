<#
.SYNOPSIS
    Performs comprehensive system maintenance, cleanup, and optimization tasks on a Windows system.

.DESCRIPTION
    This script is designed to automate the routine tasks required to keep a Windows system running
    smoothly. It includes functions for clearing temporary files, optimizing storage, running
    health checks (SFC/DISM), and clearing system caches.

.PARAMETER CleanTemp
    Execute the function to clear user and system temporary files, logs, and prefetch data.

.PARAMETER OptimizeDisk
    Execute the function to run optimization (defrag/trim) on all local drives.

.PARAMETER HealthCheck
    Execute the function to run System File Checker (SFC) and DISM health checks.

.PARAMETER ClearDNS
    Execute the function to flush the DNS Resolver Cache.

.EXAMPLE
    # Run all maintenance tasks (default behavior)
    .\Ultimate_System_Maintenance.ps1

.EXAMPLE
    # Only run the system health checks and clear temporary files
    .\Ultimate_System_Maintenance.ps1 -HealthCheck -CleanTemp

.NOTES
    Requires Administrator privileges to run most maintenance tasks successfully.
    Author: Gemini
    Version: 1.0
#>

# --- Configuration Section ---
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$CleanTemp = $true,

    [Parameter(Mandatory=$false)]
    [switch]$OptimizeDisk = $true,

    [Parameter(Mandatory=$false)]
    [switch]$HealthCheck = $true,

    [Parameter(Mandatory=$false)]
    [switch]$ClearDNS = $true
)

$ScriptName = "Ultimate Maintenance Script"

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "--- $($ScriptName) ---" -ForegroundColor Yellow
    Write-Error "❌ ERROR: This script must be run with Administrator privileges. Please right-click and 'Run as Administrator'." -Category PermissionDenied
    exit 1
}

# Temporarily set Execution Policy for the current PowerShell session to allow script execution
Write-Host "Setting execution policy to Bypass for this session..." -ForegroundColor Gray
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null
} catch {
    Write-Warning "Could not set execution policy: $($_.Exception.Message)"
}

Write-Host "`n=========================================================" -ForegroundColor Cyan
Write-Host "        $($ScriptName) - Starting Comprehensive Scan" -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan

# --- Function Definitions ---

function Clear-TempFiles {
    <#
    .SYNOPSIS
        Clears temporary files from user profiles and system locations.
    #>
    Write-Host "`n[1/4] Starting Temporary File Cleanup..." -ForegroundColor Green
    $CleanupFolders = @(
        "$env:TEMP\*",
        "$env:windir\Temp\*",
        "$env:UserProfile\AppData\Local\Temp\*",
        "$env:windir\SoftwareDistribution\Download\*"
    )
    $CleanupFolders | ForEach-Object {
        $Folder = $_
        Write-Host "  -> Cleaning: $Folder" -ForegroundColor Gray
        try {
            # Use -Force and -ErrorAction SilentlyContinue to skip locked files without stopping
            Remove-Item -Path $Folder -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Host "  -> Cleanup of '$Folder' completed." -ForegroundColor DarkGreen
        }
        catch {
            Write-Warning "Failed to clear some items in $_. Some files may be in use."
        }
    }

    # Clear Recycle Bin (for all user profiles)
    try {
        Write-Host "  -> Clearing Recycle Bin..." -ForegroundColor Gray
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Host "  -> Recycle Bin successfully cleared." -ForegroundColor DarkGreen
    }
    catch {
        Write-Warning "Failed to clear the Recycle Bin: $($_.Exception.Message)"
    }
}

function Clear-DNSCache {
    <#
    .SYNOPSIS
        Flushes the DNS Resolver Cache.
    #>
    Write-Host "`n[2/4] Starting DNS Cache Flush..." -ForegroundColor Green
    try {
        ipconfig /flushdns
        Write-Host "  -> Successfully flushed the DNS Resolver Cache." -ForegroundColor DarkGreen
    }
    catch {
        Write-Warning "Failed to execute 'ipconfig /flushdns'. Error: $($_.Exception.Message)"
    }
}

function Run-SystemHealthChecks {
    <#
    .SYNOPSIS
        Runs SFC and DISM tools to check and repair system file integrity.
    #>
    Write-Host "`n[3/4] Starting System Health Checks (SFC & DISM)..." -ForegroundColor Green

    # --- 3a. System File Checker (SFC) ---
    Write-Host "  -> Running SFC /SCANNOW (System File Checker). This may take several minutes..." -ForegroundColor Yellow
    try {
        $SFCResult = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -Passthru
        if ($SFCResult.ExitCode -eq 0) {
            Write-Host "  -> SFC scan completed successfully." -ForegroundColor DarkGreen
        } else {
            Write-Warning "SFC scan finished with exit code $($SFCResult.ExitCode). Check the CBS.log for details."
        }
    }
    catch {
        Write-Error "SFC execution failed: $($_.Exception.Message)"
    }

    # --- 3b. Deployment Image Servicing and Management (DISM) ---
    Write-Host "  -> Running DISM Health Check. This may take longer..." -ForegroundColor Yellow
    try {
        # Check Health
        Write-Host "     -> Checking image health (CheckHealth)..." -ForegroundColor Gray
        Start-Process -FilePath "Dism.exe" -ArgumentList "/Online /Cleanup-Image /CheckHealth" -Wait -NoNewWindow -Passthru | Out-Null

        # Scan Health (More thorough check if needed)
        # Write-Host "     -> Scanning image health (ScanHealth)..." -ForegroundColor Gray
        # Start-Process -FilePath "Dism.exe" -ArgumentList "/Online /Cleanup-Image /ScanHealth" -Wait -NoNewWindow -Passthru | Out-Null

        # Restore Health (Repair image if corruption is found)
        Write-Host "     -> Attempting to restore image health (RestoreHealth)..." -ForegroundColor Gray
        $DISMResult = Start-Process -FilePath "Dism.exe" -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -Passthru
        if ($DISMResult.ExitCode -eq 0) {
            Write-Host "  -> DISM health checks completed successfully." -ForegroundColor DarkGreen
        } else {
            Write-Warning "DISM execution finished with exit code $($DISMResult.ExitCode). Review logs for details."
        }
    }
    catch {
        Write-Error "DISM execution failed: $($_.Exception.Message)"
    }
}

function Optimize-Disk {
    <#
    .SYNOPSIS
        Optimizes all local, fixed drives (runs TRIM for SSDs, Defrag for HDDs).
    #>
    Write-Host "`n[4/4] Starting Disk Optimization (Defrag/TRIM)..." -ForegroundColor Green
    
    # Get all local, fixed drives
    $Drives = Get-Disk | Where-Object {$_.BusType -ne 'USB' -and $_.IsSystem -eq $true}
    
    if ($Drives.Count -eq 0) {
        Write-Warning "No local, fixed drives found to optimize."
        return
    }

    $Drives | ForEach-Object {
        $DriveLetter = $_.Partition -as [string]
        if ($DriveLetter) {
            Write-Host "  -> Optimizing Drive $($DriveLetter[0]):" -ForegroundColor Yellow
            try {
                # PowerShell command to optimize disk. Handles SSD (TRIM) and HDD (Defrag) automatically.
                Optimize-Volume -DriveLetter $DriveLetter[0] -ReTrim -ErrorAction Stop -Verbose
                Write-Host "  -> Optimization on $($DriveLetter[0]): finished successfully." -ForegroundColor DarkGreen
            }
            catch {
                Write-Warning "Failed to optimize drive $($DriveLetter[0]): $($_.Exception.Message)"
            }
        }
    }
}

# --- Main Execution Block ---

if ($CleanTemp) {
    Clear-TempFiles
} else {
    Write-Host "`n[Skipping] Temporary File Cleanup." -ForegroundColor Gray
}

if ($ClearDNS) {
    Clear-DNSCache
} else {
    Write-Host "`n[Skipping] DNS Cache Flush." -ForegroundColor Gray
}

if ($HealthCheck) {
    Run-SystemHealthChecks
} else {
    Write-Host "`n[Skipping] System Health Checks (SFC & DISM)." -ForegroundColor Gray
}

if ($OptimizeDisk) {
    Optimize-Disk
} else {
    Write-Host "`n[Skipping] Disk Optimization." -ForegroundColor Gray
}

Write-Host "`n=========================================================" -ForegroundColor Cyan
Write-Host "        $($ScriptName) - Maintenance Complete!" -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan