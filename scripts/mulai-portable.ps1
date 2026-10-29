param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
Set-Location -LiteralPath $script:PortableRepoRoot
$taskNode = Get-ProjectNode
$taskGit = Get-Command git -ErrorAction Stop
Write-Output ('Repo: ' + $script:PortableRepoRoot)
Write-Output ('Node: ' + $taskNode)
& $taskNode --version
& $taskGit.Source --version
& $taskGit.Source status --short --branch
if ($LASTEXITCODE -ne 0) { throw 'Git gagal membaca repo' }
Write-Output ('WORKING SHA256: ' + (Get-FileHash -LiteralPath 'places/RobloxLearningMedia-WORKING.rbxl').Hash)
if ($CheckOnly) { Write-Output 'CheckOnly: tidak memasang plugin, menjalankan bridge/Studio, pull, atau mengubah place.'; return }
foreach ($taskHelper in @('install-studio-bridge.ps1','start-studio-bridge.ps1')) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot $taskHelper)
    if ($LASTEXITCODE -ne 0) { throw ('Helper gagal: ' + $taskHelper) }
}
Write-Output ''
Write-Output 'Buka Studio dan Codex, login bila diminta. Buka WORKING dan folder repo yang dicetak di atas.'
Write-Output 'Jika plugin baru dipasang, buka ulang Studio. Tanggapi izin localhost/script bila muncul.'
Write-Output 'AI: baca konteks/log/desain; periksa status bridge online/Edit dan source sinkron sebelum mengubah game.'
Write-Output 'Tidak ada pull otomatis: jika ada edit dari PC lain, pakai TERMINAL-PORTABLE dan pull saat repo bersih sebelum membuka Studio.'
Write-Output 'Sebelum pulang: Stop + Save Studio, perbarui konteks/log, tutup place, lalu SELESAI-PORTABLE.'
