param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [switch]$Write
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repoRoot "migration-v2.syncback.project.json"
$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path

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

$arguments = @(
    "syncback",
    $projectPath,
    "--input",
    $resolvedInput,
    "--non-interactive"
)

if (-not $Write) {
    $arguments += "--dry-run"
    $arguments += "--list"
    Write-Output "Mode pratinjau: tidak ada file source yang diubah."
} else {
    Write-Output "Mode tulis: perubahan dari place akan diterapkan ke migration-v2/source."
}

& $rojoExe @arguments
if ($LASTEXITCODE -ne 0) {
    throw "Syncback Rojo gagal dengan exit code $LASTEXITCODE."
}

if (-not $Write) {
    Write-Output "Periksa daftar di atas. Jalankan ulang dengan -Write hanya jika perubahan sesuai."
}
