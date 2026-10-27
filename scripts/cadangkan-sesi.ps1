param([string]$DestinationDirectory = (Join-Path $PSScriptRoot '../../session-backups'))

# Cadangan penyelamatan file place; tidak menyimpan Studio atau menggantikan push Git.
. (Join-Path $PSScriptRoot 'warnet-common.ps1')
Assert-ProjectPlace
if ([string]::IsNullOrWhiteSpace($DestinationDirectory)) { throw 'Folder tujuan wajib diisi.' }
$taskDestination = [System.IO.Path]::GetFullPath($DestinationDirectory)
$taskStamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
$taskName = 'roblox-session-' + $taskStamp + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8)
$taskFolder = Join-Path $taskDestination $taskName
$taskArchive = $taskFolder + '.zip'
$taskBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:PlacePath).Hash
New-Item -ItemType Directory -Path $taskFolder -ErrorAction Stop | Out-Null
$taskCopy = Join-Path $taskFolder 'RobloxLearningMedia-WORKING.rbxl'
Copy-Item -LiteralPath $script:PlacePath -Destination $taskCopy -ErrorAction Stop
$taskCopied = (Get-FileHash -Algorithm SHA256 -LiteralPath $taskCopy).Hash
if ($taskBefore -ne $taskCopied) { throw 'Salinan tidak cocok. Stop/Save Studio dahulu, lalu ulangi cadangan.' }
$taskManifest = [ordered]@{
    createdUtc = [DateTime]::UtcNow.ToString('o')
    purpose = 'Cadangan file place tersimpan, bukan seluruh repository atau hasil Play'
    file = 'RobloxLearningMedia-WORKING.rbxl'
    bytes = (Get-Item -LiteralPath $taskCopy).Length
    sha256 = $taskCopied
    head = (Invoke-ProjectGit -GitArguments @('rev-parse','HEAD') | Select-Object -Last 1)
    gitStatus = @(Invoke-ProjectGit -GitArguments @('status','--short','--branch'))
    play = 'Belum diverifikasi oleh script; isi hasil aktual di catatan sesi'
    recovery = 'Buka salinan untuk penyelamatan; jangan menimpa WORKING lain tanpa membandingkan versi. Commit/source/berkas bukti tidak disertakan.'
}
$taskManifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $taskFolder 'manifest.json') -Encoding UTF8
Compress-Archive -LiteralPath $taskCopy,(Join-Path $taskFolder 'manifest.json') -DestinationPath $taskArchive -ErrorAction Stop
$taskAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $script:PlacePath).Hash
if ($taskBefore -ne $taskAfter) { throw 'WORKING berubah selama pencadangan; paket belum dinyatakan selesai. Stop/Save lalu ulangi.' }
$taskArchiveHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $taskArchive).Hash
($taskArchiveHash + '  ' + [System.IO.Path]::GetFileName($taskArchive)) | Set-Content -LiteralPath ($taskArchive + '.sha256') -Encoding ASCII
Write-Output ('Cadangan selesai: ' + $taskArchive)
Write-Output ('SHA256 WORKING: ' + $taskCopied)
Write-Output ('SHA256 ZIP: ' + $taskArchiveHash)
Write-Output 'Salin ZIP dan .sha256 ke media pribadi. Cadangan di PC yang sama belum melindungi dari reset PC.'
Write-Output 'Ini bukan push, bukan Save Studio, dan bukan cadangan seluruh clone. Simpan bukti gambar serta commit lokal secara terpisah.'
