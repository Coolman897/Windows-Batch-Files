@echo off
title Windows Copilot Disabler (Run as Administrator)
cls

REM =========================================================
REM --- DIGITAL DEFENDER'S SCRIPT SIGNATURE ---
REM =========================================================
REM PROJECT: OS Optimization and Security Suite
REM AUTHOR: [Coolman]
REM MISSION: Maintaining a fast, clean, and private Windows environment.
REM CREATION DATE: 2025-11-07
REM LAST MODIFIED: 2025-11-07
REM NOTE: Always run this script as Administrator for full system access.
REM =========================================================


echo =========================================================
echo  STARTING WINDOWS COPILOT DISABLER
echo =========================================================
echo.
echo WARNING: This script modifies key Windows Registry settings.
echo It attempts to hide the Copilot icon from the Taskbar.
echo Please run this as Administrator.
pause

:: --- Disable Windows Copilot via Registry ---
echo.
echo --- [1/2] Attempting to Disable Copilot Feature... ---

:: Path for Windows 11 23H2 (and later) or Windows 10 updates
:: The "Microsoft\Windows\Shell\Copilot" key might not exist, but REG ADD creates it.
REG ADD "HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat" /v "IsCopilotAvailable" /t REG_DWORD /d 0 /f >nul

echo Copilot setting updated in registry.

:: --- Optional: Hide the Copilot Taskbar Icon ---
echo.
echo --- [2/2] Hiding Copilot Taskbar Icon (if feature is present)... ---
:: This sets the icon's visibility setting to 'Off'.
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul

echo Copilot icon setting updated.

echo.
echo =========================================================
echo  COPILOT DISABLER COMPLETE!
echo  Please RESTART your computer or restart Explorer
echo  for these changes to take full effect.
echo =========================================================

pause
cls
echo Exiting Copilot Disabler.
timeout /t 2 /nobreak >nul
exit

