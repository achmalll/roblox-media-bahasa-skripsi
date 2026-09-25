param(
    [string]$OutputPath = "migration-v2/build/RobloxLearningMedia-MIGRATION-V2.rbxl"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repoRoot "migration-v2.syncback.project.json"

$rojoCommand = Get-Command rojo -ErrorAction SilentlyContinue
if ($rojoCommand) {
    $rojoExe = $rojoCommand.Source
} else {
    $localRojo = Join-Path $repoRoot ".tools/rojo-7.7.0/bin/rojo.exe"
    if (-not (Test-Path -LiteralPath $localRojo)) {
        throw "Rojo 7.7.0 tidak ditemukan. Jalankan 'rokit install' atau pasang binary resmi Rojo 7.7.0."
    }
    $rojoExe = $localRojo
}

if ([System.IO.Path]::IsPathRooted($OutputPath)) {
    $resolvedOutput = $OutputPath
} else {
    $resolvedOutput = Join-Path $repoRoot $OutputPath
}

$outputDirectory = Split-Path -Parent $resolvedOutput
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

& $rojoExe build $projectPath --output $resolvedOutput
if ($LASTEXITCODE -ne 0) {
    throw "Build Rojo gagal dengan exit code $LASTEXITCODE."
}

Write-Output "Build selesai: $resolvedOutput"
