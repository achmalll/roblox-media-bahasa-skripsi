param()
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
$taskRecordPath = Join-Path $script:PortableRepoRoot 'local-rbxl/bridge/process.json'
if (-not (Test-Path -LiteralPath $taskRecordPath)) { Write-Output 'Tidak ada receipt PID bridge sesi ini; tidak menghentikan proses lain.'; return }
$taskRecord = Get-Content -LiteralPath $taskRecordPath -Raw | ConvertFrom-Json
if ($taskRecord.workspaceRoot -ne $script:PortableRepoRoot) { throw 'Receipt berasal dari lokasi/PC lain. Jalankan MULAI pada PC ini terlebih dahulu.' }
$taskProcess = Get-Process -Id $taskRecord.pid -ErrorAction SilentlyContinue
if (-not $taskProcess) { Write-Output 'Proses bridge yang tercatat sudah berhenti.'; return }
if ($taskProcess.Path -ne $taskRecord.nodePath -or $taskProcess.StartTime.ToUniversalTime().ToString('o') -ne $taskRecord.startTimeUtc) { throw 'Identitas PID tidak cocok; proses tidak dihentikan.' }
$taskHealth = Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{'X-Codex-Bridge'='rbxl-v1'} -ContentType 'application/json' -Body '{}' -TimeoutSec 3
if ($taskHealth.workspaceRoot -ne $script:PortableRepoRoot -or $taskHealth.projectKey -ne 'roblox-media-bahasa-skripsi') { throw 'Server bukan milik clone ini; tidak dihentikan.' }
Stop-Process -Id $taskProcess.Id -ErrorAction Stop
$taskProcess.WaitForExit(5000) | Out-Null
Write-Output ('Bridge clone ini dihentikan: PID ' + $taskRecord.pid)
