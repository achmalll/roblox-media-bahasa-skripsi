$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
$taskOriginal=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskNode=Get-ProjectNode
$env:Path=(Split-Path $taskNode)+';'+$env:Path
$taskFixture=Join-Path $taskOriginal ('local-rbxl/setup-integration-'+[Guid]::NewGuid().ToString('N'))
$taskRepo=Join-Path $taskFixture 'repo with spaces'
New-Item -ItemType Directory -Path (Join-Path $taskRepo 'scripts') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $taskRepo 'places') -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $taskRepo 'studio-sync') -Force | Out-Null
foreach ($taskMeta in @('.gitignore','.gitattributes')) { Copy-Item -LiteralPath (Join-Path $taskOriginal $taskMeta) -Destination (Join-Path $taskRepo $taskMeta) }
$taskFiles=@('portable-runtime.ps1','setup-runtime.ps1','setup-warnet.ps1','setup-state.cjs','start-studio-bridge.ps1','stop-studio-bridge.ps1','studio-bridge.cjs','rbxl-local.cjs','rbxl-prompt-hold.cjs')
foreach ($taskFile in $taskFiles) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $taskFile) -Destination (Join-Path (Join-Path $taskRepo 'scripts') $taskFile) }
# Isolate plugin installation and app launching. Real controller/start/stop/status code remains under test.
[IO.File]::WriteAllText((Join-Path $taskRepo 'scripts/install-studio-bridge.ps1'), '$p=Join-Path $env:LOCALAPPDATA "Roblox/Plugins/CodexLocalBridge.rbxmx"; New-Item -ItemType Directory -Path (Split-Path $p) -Force | Out-Null; [IO.File]::WriteAllText($p,"fixture plugin"); Write-Output "Fixture installer only"')
Copy-Item -LiteralPath (Join-Path $taskOriginal 'places/RobloxLearningMedia-WORKING.rbxl') -Destination (Join-Path $taskRepo 'places/RobloxLearningMedia-WORKING.rbxl')
Copy-Item -LiteralPath (Join-Path $taskOriginal 'studio-sync/project.json') -Destination (Join-Path $taskRepo 'studio-sync/project.json')
$taskConfig=Get-Content (Join-Path $taskRepo 'studio-sync/project.json') -Raw | ConvertFrom-Json
foreach ($taskScript in $taskConfig.scripts) {
    $taskDest=Join-Path $taskRepo $taskScript.file
    New-Item -ItemType Directory -Path (Split-Path $taskDest) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $taskOriginal $taskScript.file) -Destination $taskDest
}
$taskLocalAppData=$env:LOCALAPPDATA
$taskFixtureAppData=Join-Path $taskFixture 'appdata'
New-Item -ItemType Directory -Path $taskFixtureAppData -Force | Out-Null
& git init -q -b main $taskRepo
& git -C $taskRepo add -- .
& git -C $taskRepo -c user.name=Fixture -c user.email=fixture@example.invalid commit -qm 'Setup fixture'
if ($LASTEXITCODE -ne 0) { throw 'Fixture Git failed' }
try {
    $env:LOCALAPPDATA=$taskFixtureAppData
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/setup-warnet.ps1') -Mode Prepare -NoGitUpdate -Summary
    if ($LASTEXITCODE -ne 0) { throw 'Initial Prepare failed' }
    $taskReport=Get-Content (Join-Path $taskRepo 'local-rbxl/setup/latest.json') -Raw | ConvertFrom-Json
    if ($taskReport.stage -ne 'locate_or_install_studio' -or $taskReport.studioOpened -or $taskReport.editorVerified -or $taskReport.saved.matched -ne 3) { throw 'Unexpected initial readiness' }
    $taskOldProcess=Get-Content (Join-Path $taskRepo 'local-rbxl/bridge/process.json') -Raw | ConvertFrom-Json
    $taskConfig | Add-Member -NotePropertyName fixtureRevision -NotePropertyValue 2
    $taskConfig | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $taskRepo 'studio-sync/project.json') -Encoding UTF8
    # PS5 writes BOM; JSON source files in this repo are UTF8 without BOM.
    $taskJson=Get-Content (Join-Path $taskRepo 'studio-sync/project.json') -Raw
    [IO.File]::WriteAllText((Join-Path $taskRepo 'studio-sync/project.json'),$taskJson,[Text.UTF8Encoding]::new($false))
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/setup-warnet.ps1') -Mode Prepare -NoGitUpdate -Summary
    if ($LASTEXITCODE -ne 0) { throw 'Prepare after config change failed' }
    $taskNewProcess=Get-Content (Join-Path $taskRepo 'local-rbxl/bridge/process.json') -Raw | ConvertFrom-Json
    if ($taskNewProcess.pid -eq $taskOldProcess.pid) { throw 'Stale configuration reused old process' }
    $taskHealth=Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{'X-Codex-Bridge'='rbxl-v1'} -ContentType 'application/json' -Body '{}'
    if ($taskHealth.workspaceRoot -ne $taskRepo -or -not $taskHealth.configSha256) { throw 'Wrong fixture health' }
    $taskBefore=(Get-FileHash (Join-Path $taskRepo 'places/RobloxLearningMedia-WORKING.rbxl')).Hash
    $taskRead=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/setup-warnet.ps1') -CheckOnly
    if ($LASTEXITCODE -ne 0) { throw 'Read-only status failed' }
    $taskReadReport=($taskRead -join [Environment]::NewLine) | ConvertFrom-Json
    if ($taskReadReport.stage -ne 'awaiting_studio' -or $taskReadReport.saved.matches) { throw 'Status invented sync/save' }
    $taskVerify=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/setup-warnet.ps1') -Mode VerifySaved
    if ($LASTEXITCODE -ne 2) { throw 'VerifySaved did not reject pending source' }
    @'
const fs=require('node:fs'),path=require('node:path'),root=process.argv[2];
const {read}=require(path.join(root,'scripts/rbxl-local.cjs'));
const parsed=read(path.join(root,'places/RobloxLearningMedia-WORKING.rbxl'));
const config=JSON.parse(fs.readFileSync(path.join(root,'studio-sync/project.json'),'utf8'));
for(const item of config.scripts){const names=parsed.props.find(p=>p.class===item.className&&p.property==='Name').values;const i=names.findIndex(n=>n.toString()===item.instancePath.at(-1));fs.writeFileSync(path.join(root,item.file),parsed.props.find(p=>p.class===item.className&&p.property==='Source').values[i]);}
'@ | & $taskNode - $taskRepo
    if ($LASTEXITCODE -ne 0) { throw 'Fixture source alignment failed' }
    $taskVerify=& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/setup-warnet.ps1') -Mode VerifySaved
    if ($LASTEXITCODE -ne 0) { throw 'VerifySaved rejected actual matching fixture source' }
    $taskVerified=($taskVerify -join [Environment]::NewLine)|ConvertFrom-Json
    if (-not $taskVerified.saved.matches -or $taskVerified.editorVerified) { throw 'Disk verification invented editor verification' }
    if ((Get-FileHash (Join-Path $taskRepo 'places/RobloxLearningMedia-WORKING.rbxl')).Hash -ne $taskBefore) { throw 'WORKING changed' }
    Write-Output 'PASS integration: fresh clone path with spaces, real bridge start/restart, read-only status, VerifySaved rejects mismatch/accepts matching disk without claiming editor, no Studio, no WORKING mutation'
} finally {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $taskRepo 'scripts/stop-studio-bridge.ps1')
    $env:LOCALAPPDATA=$taskLocalAppData
}
