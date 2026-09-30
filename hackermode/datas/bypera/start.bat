@echo off
title Windows Explorer - Data Collection

:: Check if the PS1 file exists
if not exist "%~dp0SB-PI-Auto.ps1" (
    echo Error: SB-PI-Auto.ps1 not found!
    pause
    exit
)

:: Run the PowerShell script silently
powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0SB-PI-Auto.ps1"

:: Optional: Small delay to ensure process finishes
timeout /t 2 /nobreak > nul

exit