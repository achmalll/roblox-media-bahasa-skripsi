param([switch]$Foreground)
$ErrorActionPreference = 'Stop'
$repoPath = Split-Path -Parent $PSScriptRoot
$nodeCommand = Get-Command node -ErrorAction SilentlyContinue
$nodePath = if ($nodeCommand) { $nodeCommand.Source } else { $null }
if (-not $nodePath) {
    $runtimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI/Codex/runtimes/cua_node'
    $nodeCandidate = Get-ChildItem -LiteralPath $runtimeRoot -Filter node.exe -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($nodeCandidate) { $nodePath = $nodeCandidate.FullName }
}
if (-not $nodePath) { throw 'Node.js tidak ditemukan. Pasang Node.js LTS atau jalankan sekali Computer Use di Codex untuk menyiapkan runtime. Tidak perlu mengedit kode game.' }
$bridgeFile = Join-Path $repoPath 'scripts/studio-bridge.cjs'
if ($Foreground) { & $nodePath $bridgeFile; exit $LASTEXITCODE }
try {
    $existing = Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{ 'X-Codex-Bridge' = 'rbxl-v1' } -ContentType 'application/json' -Body '{}' -TimeoutSec 2
    if ($existing.projectKey -ne 'roblox-media-bahasa-skripsi' -or $existing.workspaceRoot -ne $repoPath) { throw 'Port dipakai bridge dari clone lain. Hentikan bridge lama terlebih dahulu.' }
    Write-Output 'Bridge untuk clone ini sudah berjalan; tidak membuat proses kedua.'
    exit 0
} catch {
    if ($_.Exception.Message -like '*clone lain*') { throw }
}
$outputDir = Join-Path $repoPath 'local-rbxl/bridge'
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$bridgeProcess = Start-Process -FilePath $nodePath -ArgumentList @('"' + $bridgeFile + '"') -WorkingDirectory $repoPath -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $outputDir 'server.stdout.log') -RedirectStandardError (Join-Path $outputDir 'server.stderr.log')
Start-Sleep -Milliseconds 700
try {
    $health = Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{ 'X-Codex-Bridge' = 'rbxl-v1' } -ContentType 'application/json' -Body '{}' -TimeoutSec 3
    if ($health.workspaceRoot -ne $repoPath) { throw 'Port dipakai proses/clone lain.' }
} catch { throw "Bridge gagal start. Periksa local-rbxl/bridge/server.stderr.log. $($_.Exception.Message)" }
Write-Output "Bridge PID $($bridgeProcess.Id) sudah merespons. Status: local-rbxl/bridge/status.json."
