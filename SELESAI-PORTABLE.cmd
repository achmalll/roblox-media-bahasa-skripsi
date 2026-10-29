@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\selesai-portable.ps1"
if errorlevel 1 echo Belum selesai. Baca pesan di atas; jangan cabut flashdisk sebelum file aman.
pause
