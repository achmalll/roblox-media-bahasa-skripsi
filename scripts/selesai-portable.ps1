param([string]$Message)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'portable-runtime.ps1')
Set-Location -LiteralPath $script:PortableRepoRoot
$taskNode = Get-ProjectNode
# Menolak selesai bila source terbaru belum benar-benar disimpan dalam file place.
& $taskNode (Join-Path $PSScriptRoot 'verify-studio-save.cjs')
if ($LASTEXITCODE -ne 0) { throw 'Source berbeda dari WORKING. Hubungkan bridge, Stop/Save dari Studio dan coba lagi. Jangan menimpa place melalui build/biner.' }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'cadangkan-sesi.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Cadangan gagal' }
function Invoke-PortableGit {
    param([string[]]$Arguments)
    # Pisahkan stdout (data/nama file) dari stderr (progress/warning) di PS5 maupun PS7.
    $taskQuoted = foreach ($taskArg in $Arguments) {
        $taskValue = '"'; $taskSlashes = 0
        foreach ($taskChar in $taskArg.ToCharArray()) {
            if ($taskChar -eq '\') { $taskSlashes++; continue }
            if ($taskChar -eq '"') { $taskValue += ('\' * ($taskSlashes * 2 + 1)) + '"' }
            else { $taskValue += ('\' * $taskSlashes) + $taskChar }
            $taskSlashes = 0
        }
        $taskValue + ('\' * ($taskSlashes * 2)) + '"'
    }
    $taskInfo = New-Object System.Diagnostics.ProcessStartInfo
    $taskInfo.FileName = (Get-Command git.exe -ErrorAction Stop).Source
    $taskInfo.Arguments = $taskQuoted -join ' '
    $taskInfo.WorkingDirectory = $script:PortableRepoRoot
    $taskInfo.UseShellExecute = $false
    $taskInfo.CreateNoWindow = $true
    $taskInfo.RedirectStandardOutput = $true
    $taskInfo.RedirectStandardError = $true
    $taskInfo.StandardOutputEncoding = [Text.Encoding]::UTF8
    $taskInfo.StandardErrorEncoding = [Text.Encoding]::UTF8
    $taskProcess = New-Object System.Diagnostics.Process
    $taskProcess.StartInfo = $taskInfo
    try {
        if (-not $taskProcess.Start()) { throw 'Git gagal dijalankan' }
        $taskOutRead = $taskProcess.StandardOutput.ReadToEndAsync()
        $taskErrRead = $taskProcess.StandardError.ReadToEndAsync()
        $taskProcess.WaitForExit()
        $taskOutput = $taskOutRead.GetAwaiter().GetResult()
        $taskErrorText = $taskErrRead.GetAwaiter().GetResult()
        $taskExit = $taskProcess.ExitCode
    } finally { $taskProcess.Dispose() }
    if ($taskExit -ne 0) { throw ('Git gagal: ' + $taskOutput + "`n" + $taskErrorText) }
    if ($taskErrorText) { Write-Host $taskErrorText.TrimEnd() }
    @($taskOutput -split '\r?\n' | Where-Object { $_ -ne '' })
}
if (@(Invoke-PortableGit -Arguments @('diff','--cached','--name-only')).Count) { throw 'Ada file staged sebelumnya. Tinjau dan selesaikan melalui TERMINAL-PORTABLE.' }
$taskTracked = @(Invoke-PortableGit -Arguments @('diff','--name-only')) | Where-Object { $_ -and $_ -ne 'default.project.json' }
$taskNew = @(Invoke-PortableGit -Arguments @('ls-files','--others','--exclude-standard')) | Where-Object { $_ -match '^(docs/|scripts/|studio-sync/|places/)|^[^/]+\.(md|cmd|mp3|aup4)$' }
$taskFiles = @(@($taskTracked) + @($taskNew) | Select-Object -Unique)
if ($taskFiles.Count) {
    if ('KONTEKS-AI.md' -notin $taskFiles -or 'docs/LOG-PENGEMBANGAN.md' -notin $taskFiles -or 'LANJUTKAN.md' -notin $taskFiles) { throw 'AI perlu memperbarui KONTEKS-AI.md, docs/LOG-PENGEMBANGAN.md dan LANJUTKAN.md untuk perubahan sesi ini sebelum commit.' }
    Write-Output 'File yang akan di-commit (default.project.json dikecualikan):'
    $taskFiles | Write-Output
    if ([string]::IsNullOrWhiteSpace($Message)) { $Message = Read-Host 'Ringkasan perubahan untuk pesan commit' }
    if ([string]::IsNullOrWhiteSpace($Message)) { throw 'Pesan commit kosong' }
    if ((Read-Host 'Commit dan push file di atas? Ketik YA') -ne 'YA') { throw 'Dibatalkan; cadangan sudah dibuat, belum commit/push.' }
    Invoke-PortableGit -Arguments (@('add','--') + $taskFiles) | Write-Output
    Invoke-PortableGit -Arguments @('diff','--cached','--check') | Write-Output
    Invoke-PortableGit -Arguments @('commit','-m',$Message) | Write-Output
}
Invoke-PortableGit -Arguments @('push','origin','main') | Write-Output
$taskRemote = @(Invoke-PortableGit -Arguments @('ls-remote','origin','refs/heads/main'))
$taskHead = (Invoke-PortableGit -Arguments @('rev-parse','HEAD') | Select-Object -Last 1)
if (($taskRemote[0] -split '\s+')[0] -ne $taskHead) { throw 'Commit remote belum cocok; jangan menganggap sinkron selesai' }
if (@(Invoke-PortableGit -Arguments @('diff','--name-only','HEAD','--','places/RobloxLearningMedia-WORKING.rbxl','studio-sync')).Count) { throw 'File game berubah lagi saat proses selesai. Simpan dan ulangi.' }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'stop-studio-bridge.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Git sudah terkirim, tetapi penghentian bridge gagal. Periksa sebelum eject.' }
Write-Output ('Push terverifikasi: ' + $taskHead)
Write-Output 'Tutup Studio/Codex/terminal yang memakai flashdisk, lalu gunakan Safely Remove/Eject Windows.'
Write-Output 'Berkas baru di luar daftar tidak di-commit otomatis. Periksa git status jika masih ada pekerjaan lain.'
