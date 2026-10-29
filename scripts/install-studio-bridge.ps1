param()
$ErrorActionPreference = 'Stop'
$repoPath = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
$nodePath = Get-ProjectNode
& $nodePath (Join-Path $repoPath 'scripts/package-studio-bridge.cjs')
if ($LASTEXITCODE -ne 0) { throw 'Pembuatan plugin gagal.' }
$pluginDirectory = Join-Path $env:LOCALAPPDATA 'Roblox/Plugins'
New-Item -ItemType Directory -Path $pluginDirectory -Force | Out-Null
$destination = Join-Path $pluginDirectory 'CodexLocalBridge.rbxmx'
$packagedPlugin = Join-Path $repoPath 'local-rbxl/bridge/CodexLocalBridge.rbxmx'
if ((Test-Path -LiteralPath $destination) -and ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $packagedPlugin -Algorithm SHA256).Hash)) {
    Write-Output 'Plugin sudah versi yang sama; tidak perlu dipasang ulang.'
    exit 0
}
if (Test-Path -LiteralPath $destination) {
    $backupDirectory = Join-Path $repoPath 'local-rbxl/bridge/plugin-backups'
    New-Item -ItemType Directory -Path $backupDirectory -Force | Out-Null
    Copy-Item -LiteralPath $destination -Destination (Join-Path $backupDirectory ((Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.rbxmx'))
}
Copy-Item -LiteralPath (Join-Path $repoPath 'local-rbxl/bridge/CodexLocalBridge.rbxmx') -Destination $destination
Write-Output "Plugin terpasang: $destination. Save pekerjaan Studio lalu buka ulang Studio agar plugin dimuat. Izinkan koneksi localhost dan akses script jika Studio meminta. Tidak mengubah game settings."
