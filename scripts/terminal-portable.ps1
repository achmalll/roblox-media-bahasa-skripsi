$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
Set-Location -LiteralPath $script:PortableRepoRoot
Write-Output ('Terminal repo: ' + $script:PortableRepoRoot)
Write-Output 'Git/Node portable dan trust khusus folder FAT32 aktif pada terminal ini saja.'
Write-Output 'Baca KONTEKS-AI.md, docs/LOG-PENGEMBANGAN.md dan docs/ACUAN-DESAIN.md saat chat baru.'
Write-Output 'Perintah rutin: git status, git pull --ff-only (hanya sebelum edit), git log -1 --oneline.'
