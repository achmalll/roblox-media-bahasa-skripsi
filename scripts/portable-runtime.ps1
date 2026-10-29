# Hanya mengatur environment proses ini/anaknya. Tidak mengubah PATH atau trust Git global.
$script:PortableRepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
function Initialize-PortableEnvironment {
    $taskTools = [IO.Path]::GetFullPath((Join-Path $script:PortableRepoRoot '../tools'))
    foreach ($taskRelative in @('PortableGit/cmd','node')) {
        $taskBin = Join-Path $taskTools $taskRelative
        if (Test-Path -LiteralPath $taskBin) { $env:Path = $taskBin + ';' + $env:Path }
    }
    # FAT32 tidak menyimpan ownership. Trust hanya repo terpilih, dalam sesi ini.
    $taskCount = 0
    if ($env:GIT_CONFIG_COUNT) { $taskCount = [int]$env:GIT_CONFIG_COUNT }
    for ($taskIndex = 0; $taskIndex -lt $taskCount; $taskIndex++) {
        if ([Environment]::GetEnvironmentVariable("GIT_CONFIG_KEY_$taskIndex") -eq 'safe.directory' -and [Environment]::GetEnvironmentVariable("GIT_CONFIG_VALUE_$taskIndex") -eq $script:PortableRepoRoot.Replace('\','/')) { return }
    }
    [Environment]::SetEnvironmentVariable("GIT_CONFIG_KEY_$taskCount",'safe.directory','Process')
    [Environment]::SetEnvironmentVariable("GIT_CONFIG_VALUE_$taskCount",$script:PortableRepoRoot.Replace('\','/'),'Process')
    $env:GIT_CONFIG_COUNT = [string]($taskCount + 1)
}
function Get-ProjectNode {
    $taskCandidates = @((Join-Path $script:PortableRepoRoot '../tools/node/node.exe'))
    $taskNode = Get-Command node -ErrorAction SilentlyContinue
    if ($taskNode) { $taskCandidates += $taskNode.Source }
    $taskRuntimeRoot = Join-Path $env:LOCALAPPDATA 'OpenAI/Codex/runtimes/cua_node'
    if (Test-Path -LiteralPath $taskRuntimeRoot) {
        $taskCandidates += @(Get-ChildItem -LiteralPath $taskRuntimeRoot -Filter node.exe -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
    }
    foreach ($taskCandidate in ($taskCandidates | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $taskCandidate -PathType Leaf)) { continue }
        $taskResolved = [IO.Path]::GetFullPath($taskCandidate)
        try {
            $taskProbe = & $taskResolved -e "process.exit(typeof require('node:zlib').zstdDecompressSync === 'function' ? 0 : 2)" 2>&1
            if ($LASTEXITCODE -eq 0) { return $taskResolved }
        } catch { }
    }
    throw 'Node dengan dukungan ZSTD tidak ditemukan. Siapkan tools/node/node.exe pada folder induk repo (paket portable resmi). Node lama di PATH belum tentu kompatibel.'
}
Initialize-PortableEnvironment
