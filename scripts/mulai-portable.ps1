param([switch]$CheckOnly,[switch]$BriefOnly)
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
$taskCardDir = Join-Path $script:PortableRepoRoot 'local-rbxl/portable'
New-Item -ItemType Directory -Path $taskCardDir -Force | Out-Null
$taskCardPath = Join-Path $taskCardDir 'SESI-MULAI.txt'
$taskPrompt = 'Lanjutkan sesi warnet sesuai LANJUTKAN.md. Baca konteks dan log terbaru, periksa koneksi, lalu pandu target berikut. Saya yang mengendalikan Play/Stop/Save Studio. Catat progres hari ini dan perbarui handoff sebelum selesai.'
$taskCard = @('MULAI SESI WARNET',('Waktu PC: ' + [DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz')),('Folder proyek Codex: ' + $script:PortableRepoRoot),('File Studio: ' + (Join-Path $script:PortableRepoRoot 'places/RobloxLearningMedia-WORKING.rbxl')),('Commit lokal: ' + (& $taskGit.Source rev-parse --short HEAD)),'','1. Buka/login Studio dan Codex. Buka folder/file di atas.','2. Jika plugin baru dipasang, buka ulang Studio dan tanggapi izin bila diminta.','3. Kirim prompt berikut di Codex:', $taskPrompt,'','Pegangan: LANJUTKAN.md. Baca ini dahulu, bukan mencari semua arsip.','Sebelum pulang: AI memperbarui KONTEKS-AI.md, docs/LOG-PENGEMBANGAN.md dan LANJUTKAN.md; pengguna Stop/Save dan tutup place, lalu SELESAI.','Status koneksi dan hasil Play tetap harus diverifikasi; kartu ini bukan bukti Studio online.')
$taskCard | Set-Content -LiteralPath $taskCardPath -Encoding UTF8
Write-Output ($taskCard -join [Environment]::NewLine)
Write-Output ('Salinan langkah/prompt: ' + $taskCardPath)
if ($BriefOnly) { Write-Output 'BriefOnly: kartu sesi dibuat, tidak memasang plugin/start bridge/Studio/Play.'; return }
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
