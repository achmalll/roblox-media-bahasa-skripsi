@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\mulai-portable.ps1"
if errorlevel 1 echo Gagal. Baca pesan di atas; jangan reset atau menimpa WORKING.
pause
