# Reusable functions; importing this file never downloads or starts anything.
function Get-StudioOpenArguments {
    param([string]$PlacePath)
    if (-not [IO.Path]::IsPathRooted($PlacePath) -or $PlacePath.Contains('"')) { throw 'Path WORKING harus absolut dan valid.' }
    '--task EditFile --localPlaceFile "' + $PlacePath + '"'
}
function Get-NodePackageDescriptor {
    param([string]$Checksums,[ValidateSet('x64','arm64','x86')][string]$Architecture)
    $taskMatches = @($Checksums -split '\r?\n' | Where-Object { $_ -match ('^[a-fA-F0-9]{64}\s+node-v22\.23\.4-win-' + $Architecture + '\.zip\s*$') })
    if ($taskMatches.Count -ne 1) { throw 'SHASUMS resmi tidak memuat tepat satu paket Node yang diharapkan.' }
    $taskParts = $taskMatches[0].Trim() -split '\s+'
    [pscustomobject]@{ FileName=$taskParts[1]; Sha256=$taskParts[0].ToLowerInvariant(); Version='22.23.4' }
}
function Assert-NodeArchiveHash {
    param([string]$Archive,[string]$Expected)
    if ((Get-FileHash -LiteralPath $Archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Expected.ToLowerInvariant()) { throw 'Checksum ZIP Node tidak cocok; paket tidak dijalankan.' }
}
function Install-ProjectNode {
    param([string]$RepoRoot)
    $taskArchRaw = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    $taskArch = switch ($taskArchRaw) { 'AMD64' {'x64'} 'ARM64' {'arm64'} 'x86' {'x86'} default {throw 'Arsitektur Node Windows tidak dikenali.'} }
    $taskBase = 'https://nodejs.org/dist/v22.23.4/'
    $taskCache = Join-Path $RepoRoot ('local-rbxl/setup/node-download-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $taskCache -Force | Out-Null
    # TLS 1.2 also supports Windows PowerShell 5.1 on a freshly installed PC.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $taskSumsPath = Join-Path $taskCache 'SHASUMS256.txt'
    Invoke-WebRequest -UseBasicParsing -Uri ($taskBase + 'SHASUMS256.txt') -OutFile $taskSumsPath -TimeoutSec 60
    $taskPackage = Get-NodePackageDescriptor -Checksums ([IO.File]::ReadAllText($taskSumsPath)) -Architecture $taskArch
    $taskZip = Join-Path $taskCache $taskPackage.FileName
    Invoke-WebRequest -UseBasicParsing -Uri ($taskBase + $taskPackage.FileName) -OutFile $taskZip -TimeoutSec 120
    Assert-NodeArchiveHash -Archive $taskZip -Expected $taskPackage.Sha256
    Expand-Archive -LiteralPath $taskZip -DestinationPath (Join-Path $taskCache 'unpacked')
    $taskPackageRoot = Join-Path (Join-Path $taskCache 'unpacked') ([IO.Path]::GetFileNameWithoutExtension($taskPackage.FileName))
    $taskExe = Join-Path $taskPackageRoot 'node.exe'
    & $taskExe -e "process.exit(typeof require('node:zlib').zstdDecompressSync === 'function' ? 0 : 2)"
    if ($LASTEXITCODE -ne 0) { throw 'Paket Node tidak mendukung ZSTD; runtime tidak dipasang.' }
    $taskDestination = Join-Path $RepoRoot 'local-rbxl/runtime/node'
    New-Item -ItemType Directory -Path $taskDestination -Force | Out-Null
    Copy-Item -LiteralPath $taskExe -Destination (Join-Path $taskDestination 'node.exe') -Force
    Copy-Item -LiteralPath (Join-Path $taskPackageRoot 'LICENSE') -Destination (Join-Path $taskDestination 'LICENSE') -Force
    [ordered]@{version=$taskPackage.Version;source=($taskBase+$taskPackage.FileName);zipSha256=$taskPackage.Sha256;installedUtc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskDestination 'provenance.json') -Encoding UTF8
    Join-Path $taskDestination 'node.exe'
}
