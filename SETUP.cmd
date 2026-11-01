@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\setup-warnet.ps1" -Mode Prepare -OpenStudio -Summary
exit /b %errorlevel%
