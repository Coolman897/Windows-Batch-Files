echo off
title System Cleaner - Delete Unused Files (Run as Administrator)
cls

REM =========================================================
REM --- DIGITAL DEFENDER'S SCRIPT SIGNATURE ---
REM =========================================================
REM PROJECT: OS Optimization and Security Suite
REM AUTHOR: [Your Coder Tag Here]
REM MISSION: Maintaining a fast, clean, and private Windows environment.
REM CREATION DATE: 2025-11-07
REM LAST MODIFIED: 2025-11-07
REM NOTE: Always run this script as Administrator for full system access.
REM =========================================================

echo =========================================================
echo  STARTING UNUSED FILE CLEANUP ROUTINE
echo =========================================================
echo.
echo WARNING: This script will delete files in common temporary and cache locations.
echo Please run this as Administrator for a more complete cleanup.
pause

:: --- 1. Clean User Temporary Files (Accessible without Admin) ---
echo.
echo --- [1/4] Cleaning User Temporary Directory (%%TEMP%%)... ---
:: Deletes files and folders in the user's local temp directory.
:: /Q suppresses the prompt for files. /S allows recursive deletion into subdirectories.
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1
echo User Temp files cleaned.

:: --- 2. Clean Windows System Temporary Files (Requires Admin) ---
echo.
echo --- [2/4] Cleaning Windows System Temporary Directory (C:\Windows\Temp)... ---
:: Deletes files and folders in the main system temp directory.
rd /s /q "C:\Windows\Temp" >nul 2>&1
mkdir "C:\Windows\Temp" >nul 2>&1
echo System Temp files cleaned.

:: --- 3. Clean Windows Prefetch Cache (Requires Admin) ---
echo.
echo --- [3/4] Cleaning Windows Prefetch Cache... ---
:: Deletes files in the Prefetch folder, which rebuilds automatically.
del /f /s /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
echo Prefetch files (.pf) cleaned.

:: --- 4. Run DISM Component Cleanup (Advanced Clean-up) ---
echo.
echo --- [4/4] Starting DISM Component Cleanup (Windows Update Caches)... ---
:: This command cleans up obsolete Windows Update components, which can free up significant space.
Dism /Online /Cleanup-Image /StartComponentCleanup
echo DISM Component Cleanup finished.

echo.
echo =========================================================
echo  UNUSED FILE CLEANUP COMPLETE!
echo  If any files were in use, they were skipped.
echo =========================================================

pause
cls
echo Exiting System Cleaner.
timeout /t 2 /nobreak >nul
exit