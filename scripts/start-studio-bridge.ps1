param([switch]$Foreground)
$ErrorActionPreference = 'Stop'
$repoPath = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
$nodePath = Get-ProjectNode
$bridgeFile = Join-Path $repoPath 'scripts/studio-bridge.cjs'
$taskConfigHash = & $nodePath -e "const f=require('node:fs'),c=require('node:crypto');process.stdout.write(c.createHash('sha256').update(JSON.stringify(JSON.parse(f.readFileSync(process.argv[1],'utf8')))).digest('hex'));" (Join-Path $repoPath 'studio-sync/project.json')
if ($LASTEXITCODE -ne 0) { throw 'Fingerprint konfigurasi bridge gagal dibaca.' }
if ($Foreground) { & $nodePath $bridgeFile; exit $LASTEXITCODE }
try {
    $existing = Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{ 'X-Codex-Bridge' = 'rbxl-v1' } -ContentType 'application/json' -Body '{}' -TimeoutSec 2
    if ($existing.projectKey -ne 'roblox-media-bahasa-skripsi' -or $existing.workspaceRoot -ne $repoPath) { throw 'Port dipakai bridge dari clone lain. Hentikan bridge lama terlebih dahulu.' }
    if ($existing.configSha256 -ne $taskConfigHash) { throw 'Konfigurasi bridge berubah. Jalankan SETUP.cmd agar bridge clone ini dihentikan terarah dan dimulai ulang.' }
    Write-Output 'Bridge untuk clone ini sudah berjalan; tidak membuat proses kedua.'
    exit 0
} catch {
    if ($_.Exception.Message -like '*clone lain*' -or $_.Exception.Message -like '*Konfigurasi bridge berubah*') { throw }
}
$outputDir = Join-Path $repoPath 'local-rbxl/bridge'
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$bridgeProcess = Start-Process -FilePath $nodePath -ArgumentList @('"' + $bridgeFile + '"') -WorkingDirectory $repoPath -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $outputDir 'server.stdout.log') -RedirectStandardError (Join-Path $outputDir 'server.stderr.log')
Start-Sleep -Milliseconds 700
try {
    $health = Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{ 'X-Codex-Bridge' = 'rbxl-v1' } -ContentType 'application/json' -Body '{}' -TimeoutSec 3
    if ($health.workspaceRoot -ne $repoPath) { throw 'Port dipakai proses/clone lain.' }
} catch { throw "Bridge gagal start. Periksa local-rbxl/bridge/server.stderr.log. $($_.Exception.Message)" }
$record = [ordered]@{ pid=$bridgeProcess.Id; workspaceRoot=$repoPath; nodePath=$nodePath; startTimeUtc=$bridgeProcess.StartTime.ToUniversalTime().ToString('o') }
$record | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outputDir 'process.json') -Encoding UTF8
Write-Output "Bridge PID $($bridgeProcess.Id) sudah merespons. Status: local-rbxl/bridge/status.json."
