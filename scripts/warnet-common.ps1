$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
$script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:PlaceRelative = 'places/RobloxLearningMedia-WORKING.rbxl'
$script:PlacePath = Join-Path $script:RepoRoot $script:PlaceRelative
$taskGit = Get-Command git -ErrorAction SilentlyContinue
if ($taskGit) { $script:GitExe = $taskGit.Source }
else {
    $taskPortable = Join-Path $script:RepoRoot '../tools/PortableGit/cmd/git.exe'
    if (-not (Test-Path -LiteralPath $taskPortable)) { throw 'Git belum tersedia. Pasang Git atau jalankan Git portable, lalu buka PowerShell kembali.' }
    $script:GitExe = (Resolve-Path -LiteralPath $taskPortable).Path
}
function Invoke-ProjectGit {
    param([string[]]$GitArguments)
    $taskPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $taskOutput = & $script:GitExe -C $script:RepoRoot @GitArguments 2>&1
    $taskExit = $LASTEXITCODE
    $ErrorActionPreference = $taskPreference
    if ($taskExit -ne 0) { throw ('Git gagal: ' + ($GitArguments -join ' ') + [Environment]::NewLine + ($taskOutput -join [Environment]::NewLine)) }
    return @($taskOutput | ForEach-Object { $_.ToString() })
}
function Assert-ProjectPlace {
    $taskTop = (Invoke-ProjectGit -GitArguments @('rev-parse','--show-toplevel') | Select-Object -Last 1)
    if ([System.IO.Path]::GetFullPath($taskTop) -ne $script:RepoRoot) { throw 'Script harus berada dalam folder scripts pada clone repository Roblox ini.' }
    if (-not (Test-Path -LiteralPath $script:PlacePath)) { throw ('Place utama tidak ditemukan: ' + $script:PlacePath) }
    $taskBytes = New-Object byte[] 8
    $taskStream = [System.IO.File]::OpenRead($script:PlacePath)
    try { $taskRead = $taskStream.Read($taskBytes,0,8) } finally { $taskStream.Dispose() }
    if ($taskRead -ne 8 -or [System.Text.Encoding]::ASCII.GetString($taskBytes) -ne '<roblox!') { throw 'Header place tidak sesuai format RBXL binary. Periksa file sebelum sinkronisasi.' }
}
function Show-ProjectPlace {
    Write-Output ('File utama: ' + $script:PlacePath)
    Write-Output ('SHA256: ' + (Get-FileHash -Algorithm SHA256 -LiteralPath $script:PlacePath).Hash)
    Invoke-ProjectGit -GitArguments @('status','--short','--branch') | Write-Output
}
