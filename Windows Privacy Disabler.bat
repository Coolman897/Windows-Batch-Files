@echo off
title Windows Privacy Disabler (Run as Administrator)
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
echo  STARTING WINDOWS PRIVACY AND TELEMETRY DISABLER
echo =========================================================
echo.
echo WARNING: This script modifies key Windows Registry settings.
echo Please run this as Administrator.
pause

:: --- 1. Disable Telemetry and Data Collection ---
echo.
echo --- [1/4] Disabling Windows Telemetry (Data Collection)... ---
:: Sets the AllowTelemetry value to 0, which is the most restrictive setting.
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul
echo Telemetry disabled.

:: --- 2. Disable Location Tracking Service ---
echo.
echo --- [2/4] Disabling Windows Location Service... ---
:: Stops and disables the geo-location service (lfsvc) that tracks your device's physical location.
sc stop "lfsvc" >nul 2>&1
sc config "lfsvc" start= disabled >nul
echo Location Service disabled.

:: --- 3. Disable Advertising ID ---
echo.
echo --- [3/4] Disabling Personalized Ads and Advertising ID... ---
:: This prevents Windows from creating a unique advertising ID tied to your account for personalized ads.
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul
echo Advertising ID disabled.

:: --- 4. Disable Cortana/Search Web Integration ---
echo.
echo --- [4/4] Disabling Web Search in Start Menu/Cortana... ---
:: Prevents your Start Menu searches from being sent to Bing/Microsoft.
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f >nul
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /t REG_DWORD /d 0 /f >nul
echo Web search integration disabled.

echo.
echo =========================================================
echo  PRIVACY SETTINGS APPLIED!
echo  A restart may be required for all settings to take full effect.
echo =========================================================

pause
cls
echo Exiting Privacy Disabler.
timeout /t 2 /nobreak >nul
exit

