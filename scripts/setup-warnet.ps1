param(
    [ValidateSet('Prepare','Status','VerifySaved')][string]$Mode='Prepare',
    [switch]$CheckOnly,
    [switch]$OpenStudio,
    [switch]$Summary,
    [switch]$NoGitUpdate
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
. (Join-Path $PSScriptRoot 'setup-runtime.ps1')
$taskRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $taskRoot
if ($CheckOnly) { $Mode='Status' }
function Invoke-SetupGit {
    param([string[]]$GitArguments)
    $taskPreference=$ErrorActionPreference; $ErrorActionPreference='Continue'
    $taskOutput=& $script:SetupGit -C $taskRoot @GitArguments 2>&1
    $taskExit=$LASTEXITCODE; $ErrorActionPreference=$taskPreference
    if ($taskExit -ne 0) { throw ('Git gagal: ' + ($taskOutput -join [Environment]::NewLine)) }
    @($taskOutput | ForEach-Object { $_.ToString() })
}
function Invoke-SetupHelper {
    param([string]$Name)
    # Avoid native pipeline handles inherited by a detached Node child in Windows PowerShell 5.1.
    $taskLogs=Join-Path $taskRoot 'local-rbxl/setup/helper-logs'
    New-Item -ItemType Directory -Path $taskLogs -Force | Out-Null
    $taskId=[Guid]::NewGuid().ToString('N')
    $taskOut=Join-Path $taskLogs ($Name+'-'+$taskId+'.out.log')
    $taskErr=Join-Path $taskLogs ($Name+'-'+$taskId+'.err.log')
    $taskScript=Join-Path $PSScriptRoot $Name
    $taskInfo=New-Object System.Diagnostics.ProcessStartInfo
    $taskInfo.FileName='powershell.exe'
    $taskInfo.Arguments='-NoProfile -ExecutionPolicy Bypass -File "'+$taskScript+'"'
    $taskInfo.WorkingDirectory=$taskRoot
    $taskInfo.UseShellExecute=$false; $taskInfo.CreateNoWindow=$true
    $taskInfo.RedirectStandardOutput=$true; $taskInfo.RedirectStandardError=$true
    $taskChild=New-Object System.Diagnostics.Process
    $taskChild.StartInfo=$taskInfo
    try {
        if (-not $taskChild.Start()) { throw ('Helper tidak dapat dimulai: '+$Name) }
        $taskOutRead=$taskChild.StandardOutput.ReadToEndAsync()
        $taskErrRead=$taskChild.StandardError.ReadToEndAsync()
        if (-not $taskChild.WaitForExit(30000)) { throw ('Helper belum selesai: '+$Name+'. Periksa log/PID, jangan mulai bridge kedua.') }
        $taskExit=$taskChild.ExitCode
        # A detached child can retain a Windows pipe. Do not await that pipe after the helper exited.
        $taskOutRead.Wait(500) | Out-Null; $taskErrRead.Wait(500) | Out-Null
        $taskOutput=if ($taskOutRead.IsCompleted) { $taskOutRead.GetAwaiter().GetResult() } else { 'Helper exited; detached bridge output is in local-rbxl/bridge/server.*.log' }
        $taskFailure=if ($taskErrRead.IsCompleted) { $taskErrRead.GetAwaiter().GetResult() } else { '' }
        [IO.File]::WriteAllText($taskOut,$taskOutput)
        [IO.File]::WriteAllText($taskErr,$taskFailure)
        if ($taskOutput) { Write-Host $taskOutput.TrimEnd() }
        if ($taskExit -ne 0) { throw ('Helper gagal: '+$Name+'. '+$taskFailure) }
    } finally { $taskChild.Dispose() }
}
try {
    $taskGit=Get-Command git.exe -ErrorAction SilentlyContinue
    $taskGitCandidates=@()
    if ($taskGit) { $taskGitCandidates+=$taskGit.Source }
    $taskGitCandidates+=@((Join-Path $taskRoot '../tools/PortableGit/cmd/git.exe'))
    if ($env:ProgramFiles) { $taskGitCandidates+=(Join-Path $env:ProgramFiles 'Git/cmd/git.exe') }
    if ($env:LOCALAPPDATA) { $taskGitCandidates+=(Join-Path $env:LOCALAPPDATA 'Programs/Git/cmd/git.exe') }
    $script:SetupGit=$taskGitCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $script:SetupGit) { throw 'Git belum tersedia. AI perlu menyiapkan Git pada PC ini dahulu; clone bukan instalasi Git.' }
    $taskTop=Invoke-SetupGit -GitArguments @('rev-parse','--show-toplevel') | Select-Object -Last 1
    if ([IO.Path]::GetFullPath($taskTop) -ne $taskRoot) { throw 'Jalankan setup dari clone repository yang utuh.' }
    $taskGitDirty=@(Invoke-SetupGit -GitArguments @('status','--porcelain')).Count -gt 0
    $taskBranch=Invoke-SetupGit -GitArguments @('branch','--show-current') | Select-Object -Last 1
    $taskUpdate='not_requested'
    $taskStudioProcesses=@(Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue)
    if ($Mode -eq 'Prepare' -and -not $NoGitUpdate) {
        if ($taskGitDirty) { $taskUpdate='skipped_local_changes' }
        elseif ($taskBranch -ne 'main') { throw 'Branch bukan main. AI perlu memeriksa branch sebelum memperbarui repo; tidak auto checkout/reset.' }
        else {
            Invoke-SetupGit -GitArguments @('fetch','origin','main') | ForEach-Object { Write-Host $_ }
            $taskBefore=Invoke-SetupGit -GitArguments @('rev-parse','HEAD') | Select-Object -Last 1
            $taskRemote=Invoke-SetupGit -GitArguments @('rev-parse','origin/main') | Select-Object -Last 1
            if ($taskBefore -ne $taskRemote -and $taskStudioProcesses.Count) { throw 'Repo perlu diperbarui tetapi Studio sedang terbuka. Simpan/tutup sesi yang ada, lalu jalankan setup lagi agar WORKING tidak diganti saat terbuka.' }
            Invoke-SetupGit -GitArguments @('merge','--ff-only','origin/main') | ForEach-Object { Write-Host $_ }
            $taskUpdate='fetched_fast_forward_only'
        }
    }
    $taskNode=$null
    try { $taskNode=Get-ProjectNode } catch {
        if ($Mode -ne 'Prepare') { throw 'Node dengan ZSTD belum tersedia. Jalankan SETUP.cmd untuk menyiapkan runtime resmi otomatis.' }
        Write-Host 'Menyiapkan Node resmi lokal repo (tanpa admin/PATH global), verifikasi SHA256...'
        $taskNode=Install-ProjectNode -RepoRoot $taskRoot
    }
    $taskStudio=$null
    $taskVersions=Join-Path $env:LOCALAPPDATA 'Roblox/Versions'
    if (Test-Path -LiteralPath $taskVersions) {
        $taskStudio=Get-ChildItem -LiteralPath $taskVersions -Directory | ForEach-Object {
            $taskCandidate=Join-Path $_.FullName 'RobloxStudioBeta.exe'
            if (Test-Path -LiteralPath $taskCandidate) { Get-Item -LiteralPath $taskCandidate }
        } | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
    }
    $taskPluginChanged=$false; $taskOpened=$false
    if ($Mode -eq 'Prepare') {
        $taskConfigHash=& $taskNode -e "const f=require('node:fs'),c=require('node:crypto');process.stdout.write(c.createHash('sha256').update(JSON.stringify(JSON.parse(f.readFileSync(process.argv[1],'utf8')))).digest('hex'));" (Join-Path $taskRoot 'studio-sync/project.json')
        if ($LASTEXITCODE -ne 0) { throw 'Fingerprint konfigurasi gagal dibaca.' }
        $taskExisting=$null
        try { $taskExisting=Invoke-RestMethod -Uri 'http://127.0.0.1:34873/health' -Method Post -Headers @{'X-Codex-Bridge'='rbxl-v1'} -ContentType 'application/json' -Body '{}' -TimeoutSec 2 } catch { }
        if ($taskExisting -and $taskExisting.workspaceRoot -eq $taskRoot -and $taskExisting.configSha256 -ne $taskConfigHash) {
            Invoke-SetupHelper -Name 'stop-studio-bridge.ps1'
        }
        $taskPlugin=Join-Path $env:LOCALAPPDATA 'Roblox/Plugins/CodexLocalBridge.rbxmx'
        $taskOldHash=if (Test-Path -LiteralPath $taskPlugin) { (Get-FileHash -LiteralPath $taskPlugin).Hash } else { '' }
        foreach ($taskHelper in @('install-studio-bridge.ps1','start-studio-bridge.ps1')) {
            Invoke-SetupHelper -Name $taskHelper
        }
        $taskPluginChanged=$taskOldHash -ne (Get-FileHash -LiteralPath $taskPlugin).Hash
        if ($OpenStudio -and $taskStudio -and $taskStudioProcesses.Count -eq 0) {
            $taskWorking=Join-Path $taskRoot 'places/RobloxLearningMedia-WORKING.rbxl'
            Start-Process -FilePath $taskStudio.FullName -ArgumentList (Get-StudioOpenArguments -PlacePath $taskWorking) | Out-Null
            $taskOpened=$true
        }
    }
    $taskRaw=& $taskNode (Join-Path $PSScriptRoot 'setup-state.cjs') $taskRoot
    if ($LASTEXITCODE -ne 0) { throw 'Pemeriksaan source/file/bridge gagal dibaca.' }
    $taskReport=($taskRaw -join [Environment]::NewLine) | ConvertFrom-Json
    $taskReport | Add-Member -NotePropertyName git -NotePropertyValue ([ordered]@{head=(Invoke-SetupGit -GitArguments @('rev-parse','HEAD') | Select-Object -Last 1);branch=$taskBranch;dirty=$taskGitDirty;update=$taskUpdate}) -Force
    $taskReport | Add-Member -NotePropertyName mode -NotePropertyValue $Mode -Force
    $taskReport | Add-Member -NotePropertyName nodePath -NotePropertyValue $taskNode -Force
    $taskReport | Add-Member -NotePropertyName studioDetected -NotePropertyValue ([bool]$taskStudio) -Force
    $taskReport | Add-Member -NotePropertyName studioOpened -NotePropertyValue $taskOpened -Force
    $taskReport | Add-Member -NotePropertyName pluginChanged -NotePropertyValue $taskPluginChanged -Force
    if ($Mode -eq 'Prepare' -and -not $taskStudio) { $taskReport.stage='locate_or_install_studio'; $taskReport.next='AI_find_nonstandard_install_or_follow_official_setup' }
    elseif ($Mode -eq 'Prepare' -and $taskPluginChanged -and $taskStudioProcesses.Count) { $taskReport.stage='restart_studio_after_save'; $taskReport.next='user_save_and_close_existing_studio_then_reopen_working' }
    $taskJson=$taskReport | ConvertTo-Json -Depth 12
    if ($Mode -eq 'Prepare') {
        $taskState=Join-Path $taskRoot 'local-rbxl/setup'
        New-Item -ItemType Directory -Path $taskState -Force | Out-Null
        $taskJson | Set-Content -LiteralPath (Join-Path $taskState 'latest.json') -Encoding UTF8
    }
    if ($Summary) {
        Write-Output ('Tahap: '+$taskReport.stage)
        Write-Output ('Source editor: '+$taskReport.editorSynced+'/'+$taskReport.expectedSources)
        Write-Output ('Source dalam WORKING: '+$taskReport.saved.matched+'/'+$taskReport.saved.total)
        Write-Output ('Tindakan AI berikut: '+$taskReport.next)
        Write-Output ('File Studio: '+$taskReport.workingPath)
        if ($Mode -eq 'Prepare') { Write-Output 'AI: baca laporan local-rbxl/setup/latest.json dan teruskan workflow; ini belum bukti Play/cloud.' }
    } else { Write-Output $taskJson }
    if ($Mode -eq 'VerifySaved' -and -not $taskReport.saved.matches) { exit 2 }
} catch {
    [ordered]@{schemaVersion=1;stage='setup_failed';error=$_.Exception.Message;workspaceRoot=$taskRoot;gitUpdate=$taskUpdate;placeSavePerformed=$false} | ConvertTo-Json -Depth 5 | Write-Output
    exit 1
}
