@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\install-studio-bridge.ps1"
if errorlevel 1 goto failed
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start-studio-bridge.ps1"
if errorlevel 1 goto failed
echo.
echo Buka WORKING di Studio. Jika plugin baru dipasang/diperbarui, Save lalu buka ulang Studio.
echo Izinkan koneksi localhost dan akses script jika Studio meminta. Jangan sambungkan dua Studio sekaligus.
pause
exit /b 0
:failed
echo Setup gagal. Jangan mengedit konfigurasi game untuk memperbaiki setup; baca pesan di atas.
pause
exit /b 1
