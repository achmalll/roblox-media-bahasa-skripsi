param([string]$Message = 'Simpan sesi Roblox',[switch]$CheckOnly)
. (Join-Path $PSScriptRoot 'warnet-common.ps1')
Assert-ProjectPlace
if ($CheckOnly) { Show-ProjectPlace; Write-Output 'Pemeriksaan saja: tidak add, commit, atau push.'; return }
if ([string]::IsNullOrWhiteSpace($Message)) { throw 'Pesan commit harus berisi ringkasan pekerjaan.' }
$taskStaged = Invoke-ProjectGit -GitArguments @('diff','--cached','--name-only')
if (@($taskStaged | Where-Object { $_ -and $_ -ne $script:PlaceRelative }).Count -gt 0) { throw 'Ada file lain yang sudah di-stage. Selesaikan commit tersebut dahulu; script hanya mengurus WORKING.' }
$taskChanged = Invoke-ProjectGit -GitArguments @('status','--porcelain','--',$script:PlaceRelative)
if ($taskChanged.Count -gt 0) {
    Invoke-ProjectGit -GitArguments @('add','--',$script:PlaceRelative) | Write-Output
    Invoke-ProjectGit -GitArguments @('commit','-m',$Message) | Write-Output
} else { Write-Output 'WORKING tidak berubah; tidak membuat commit kosong.' }
Invoke-ProjectGit -GitArguments @('push') | Write-Output
Invoke-ProjectGit -GitArguments @('fetch','origin') | Write-Output
$taskRemaining = Invoke-ProjectGit -GitArguments @('rev-list','--count','@{u}..HEAD')
if ([int]($taskRemaining | Select-Object -Last 1) -ne 0) { throw 'Masih ada commit lokal yang belum terkirim. Jangan pindah komputer sebelum push selesai.' }
$taskDirty = Invoke-ProjectGit -GitArguments @('status','--porcelain','--',$script:PlaceRelative)
if ($taskDirty.Count -gt 0) { throw 'WORKING berubah lagi sesudah commit. Save terakhir, lalu jalankan script kembali.' }
Show-ProjectPlace
Write-Output 'Commit lokal sudah terkirim. Di PC berikutnya jalankan mulai-warnet.ps1 sebelum membuka Studio.'
Write-Output 'Script hanya mengirim file yang sudah disimpan; ia tidak menyimpan perubahan yang masih terbuka di Studio.'
