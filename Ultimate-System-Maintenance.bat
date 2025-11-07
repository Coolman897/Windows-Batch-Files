@echo off
title Ultimate Windows Maintenance Script (Full Maintenance - Run as Administrator)
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
echo  STARTING FULL SYSTEM DIAGNOSTIC AND MAINTENANCE ROUTINE
echo =========================================================
echo.
echo WARNING: This routine will schedule a CHKDSK which requires a reboot.
echo Please do not interrupt the process.
pause

:: 1. Run SFC
echo.
echo --- [1/4] Starting SFC /SCANNOW (System File Checker)... ---
sfc /scannow
echo SFC process complete.

:: 2. Run DISM RestoreHealth
echo.
echo --- [2/4] Starting DISM RestoreHealth (System Image Repair)... ---
echo NOTE: This process can take over an hour and may appear stuck.
Dism /Online /Cleanup-Image /ScanHealth
Dism /Online /Cleanup-Image /RestoreHealth
echo DISM process complete.

:: 3. System Clean-up
echo.
echo --- [3/4] Starting System Clean-up (Temp Files, Caches)... ---
:: Removes temporary files, log files, and cached data from common locations
del /f /s /q "%TEMP%\*.*"
del /f /s /q "C:\Windows\Temp\*.*"
Dism /Online /Cleanup-Image /StartComponentCleanup
echo System Clean-up complete.

:: 4. Run CHKDSK (Moved to the end)
echo.
echo --- [4/4] Scheduling CHKDSK /f /r on C: drive... ---
echo **CRITICAL WARNING**: This requires a system **REBOOT** and will take a long time to run.
chkdsk C: /f /r
echo CHKDSK has been scheduled.

echo.
echo =========================================================
echo  FULL MAINTENANCE ROUTINE COMPLETE!
echo  Please **REBOOT** your computer **NOW** to run the scheduled CHKDSK.
echo =========================================================

pause
cls
echo Exiting Maintenance Tool. Thank you!
timeout /t 2 /nobreak >nul
exit