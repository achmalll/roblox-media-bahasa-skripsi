param([switch]$CheckOnly,[switch]$Offline,[switch]$OpenStudio)
. (Join-Path $PSScriptRoot 'warnet-common.ps1')
Assert-ProjectPlace
if ($CheckOnly) { Show-ProjectPlace; Write-Output 'Pemeriksaan saja: tidak pull, membuka Studio, atau mengubah file.'; return }
$taskChanged = Invoke-ProjectGit -GitArguments @('status','--porcelain','--',$script:PlaceRelative)
if ($taskChanged.Count -gt 0) { throw 'WORKING memiliki perubahan lokal. Simpan dan jalankan selesai-warnet.ps1 sebelum pull; jangan reset atau menimpa file.' }
if ($Offline) { Write-Warning 'Mode offline: versi GitHub belum diperiksa. Pastikan ini salinan sesi terakhir sebelum mengedit.' }
else { Invoke-ProjectGit -GitArguments @('pull','--ff-only') | Write-Output }
Assert-ProjectPlace
Show-ProjectPlace
Write-Output 'Buka file utama di atas. Sesudah mengedit, Save to File ke path yang sama.'
if ($OpenStudio) { Start-Process -FilePath $script:PlacePath }
