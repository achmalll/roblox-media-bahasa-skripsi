$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'setup-runtime.ps1')
if ((Get-StudioOpenArguments -PlacePath 'C:\folder with spaces\place.rbxl') -ne '--task EditFile --localPlaceFile "C:\folder with spaces\place.rbxl"') { throw 'Studio CLI quoting failed' }
$taskHash='a' * 64
$taskDescriptor=Get-NodePackageDescriptor -Checksums ($taskHash + '  node-v22.23.4-win-x64.zip') -Architecture x64
if ($taskDescriptor.Sha256 -ne $taskHash -or $taskDescriptor.FileName -ne 'node-v22.23.4-win-x64.zip') { throw 'Descriptor mismatch' }
$taskRejected=$false
try { Get-NodePackageDescriptor -Checksums ($taskHash+'  ../node-v22.23.4-win-x64.zip') -Architecture x64 | Out-Null } catch {$taskRejected=$true}
if (-not $taskRejected) { throw 'Unsafe package filename accepted' }
$taskRejected=$false
try { Get-NodePackageDescriptor -Checksums (($taskHash+'  node-v22.23.4-win-x64.zip')+"`n"+($taskHash+'  node-v22.23.4-win-x64.zip')) -Architecture x64 | Out-Null } catch {$taskRejected=$true}
if (-not $taskRejected) { throw 'Duplicate package accepted' }
$taskFixture=Join-Path (Join-Path $PSScriptRoot '../local-rbxl') ('setup-test-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $taskFixture -Force | Out-Null
$taskFile=Join-Path $taskFixture 'not-an-executable.zip'
[IO.File]::WriteAllText($taskFile,'fixture only')
$taskActual=(Get-FileHash -LiteralPath $taskFile).Hash
Assert-NodeArchiveHash -Archive $taskFile -Expected $taskActual
$taskRejected=$false
try { Assert-NodeArchiveHash -Archive $taskFile -Expected $taskHash } catch {$taskRejected=$true}
if (-not $taskRejected) { throw 'Corrupt archive accepted' }
foreach ($taskPath in @('setup-runtime.ps1','setup-warnet.ps1','portable-runtime.ps1')) {
    $taskTokens=$null; $taskErrors=$null
    [System.Management.Automation.Language.Parser]::ParseFile((Join-Path $PSScriptRoot $taskPath),[ref]$taskTokens,[ref]$taskErrors) | Out-Null
    if ($taskErrors.Count) { throw ($taskErrors | Out-String) }
}
Write-Output 'PASS runtime setup: official descriptor, path/duplicate rejection, checksum mismatch, PowerShell parser'
