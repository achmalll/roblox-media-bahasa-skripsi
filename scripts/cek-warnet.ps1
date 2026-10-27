param([string]$ProjectDirectory = (Join-Path $PSScriptRoot '..'))

# Pemeriksaan lokal saja: tidak install, login, pull, menulis config, atau membuka Studio.
$ErrorActionPreference = 'Stop'
$taskProject = [System.IO.Path]::GetFullPath($ProjectDirectory)
$taskGit = Get-Command git -ErrorAction SilentlyContinue
$taskPortable = Join-Path $taskProject '../tools/PortableGit/cmd/git.exe'
$taskGitExe = if ($taskGit) { $taskGit.Source } elseif (Test-Path -LiteralPath $taskPortable) { $taskPortable } else { $null }
$taskCodex = Get-Command codex -ErrorAction SilentlyContinue
$taskMcpPath = Join-Path $env:LOCALAPPDATA 'Roblox/mcp.bat'
$taskStudioVersions = Join-Path $env:LOCALAPPDATA 'Roblox/Versions'
$taskStudioFound = @()
if (Test-Path -LiteralPath $taskStudioVersions) {
    $taskStudioFound = @(Get-ChildItem -LiteralPath $taskStudioVersions -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $taskCandidate = Join-Path $_.FullName 'RobloxStudioBeta.exe'
        if (Test-Path -LiteralPath $taskCandidate) { $taskCandidate }
    })
}
$taskCodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$taskConfigPath = Join-Path $taskCodexRoot 'config.toml'
$taskRegistered = $false
if (Test-Path -LiteralPath $taskConfigPath) {
    # Tidak mencetak isi konfigurasi karena bisa memuat rahasia server lain.
    $taskRegistered = [bool](Select-String -LiteralPath $taskConfigPath -Pattern '^\s*\[mcp_servers\.(Roblox_Studio|"Roblox_Studio"|''Roblox_Studio'')\]\s*$' -Quiet)
}
$taskPlacePath = Join-Path $taskProject 'places/RobloxLearningMedia-WORKING.rbxl'
$taskPlaceHash = if (Test-Path -LiteralPath $taskPlacePath) { (Get-FileHash -LiteralPath $taskPlacePath -Algorithm SHA256).Hash } else { 'Belum ditemukan' }
[PSCustomObject]@{
    ProjectDirectory = $taskProject
    GitFound = [bool]$taskGitExe
    StudioDetectedInStandardFolder = ($taskStudioFound.Count -gt 0)
    StudioRunning = [bool](Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue)
    CodexCliFound = [bool]$taskCodex
    StudioMcpLauncherFound = (Test-Path -LiteralPath $taskMcpPath)
    RobloxStudioEntryInUserConfig = $taskRegistered
    WorkingSha256 = $taskPlaceHash
    Connection = 'Belum diuji; konfigurasi terdaftar bukan bukti MCP terhubung'
} | Format-List | Out-String | Write-Output
if ($taskGitExe -and (Test-Path -LiteralPath $taskPlacePath)) {
    & $taskGitExe -C $taskProject status --short --branch
    if ($LASTEXITCODE -ne 0) { Write-Warning 'Folder proyek belum dikenali sebagai clone Git.' }
}
Write-Output 'Jika Studio tidak terdeteksi, periksa Start Menu; lokasi instalasi lain mungkin tidak tercakup.'
Write-Output 'CodexCliFound=False tidak membuktikan aplikasi desktop tidak terpasang. Periksa Start Menu.'
Write-Output 'Langkah berikut: buka WORKING di Studio, aktifkan MCP, lalu minta AI membaca Workspace tanpa mengubahnya.'
Write-Output 'Login akun, internet, izin aset audio dan Play perlu diperiksa langsung. Script ini tidak menguji hal tersebut.'
