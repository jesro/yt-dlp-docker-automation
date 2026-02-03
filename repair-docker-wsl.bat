@echo off
cd /d "%~dp0"

echo =================================================
echo Docker + WSL One-Time Repair Script
echo MUST be run as Administrator
echo =================================================
echo.

REM ==================================================
REM Admin check
REM ==================================================
net session >nul 2>&1
if errorlevel 1 (
    echo ERROR: This script must be run as Administrator.
    echo Right-click and choose "Run as administrator".
    pause
    exit /b 1
)

REM ==================================================
REM Enable required Windows features
REM ==================================================
echo Enabling VirtualMachinePlatform...
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

echo Enabling Windows Subsystem for Linux...
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

REM ==================================================
REM Ensure hypervisor starts
REM ==================================================
echo Enabling Hyper-V hypervisor at boot...
bcdedit /set hypervisorlaunchtype auto

REM ==================================================
REM Install / update WSL kernel
REM ==================================================
echo Installing / updating WSL...
wsl --install >nul 2>&1
wsl --update

REM ==================================================
REM Set WSL2 as default
REM ==================================================
echo Setting WSL2 as default...
wsl --set-default-version 2

REM ==================================================
REM Final message + reboot
REM ==================================================
echo.
echo =================================================
echo Repair complete.
echo A REBOOT IS REQUIRED.
echo =================================================
echo.
pause
shutdown /r /t 0