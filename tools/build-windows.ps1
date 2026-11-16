param(
    [Parameter(Mandatory=$true)][string]$Godot
)
$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Godot = (Resolve-Path -LiteralPath $Godot).Path
$buildPath = Join-Path $projectPath 'builds/windows'
New-Item -ItemType Directory -Force $buildPath | Out-Null
Set-Content -LiteralPath (Join-Path $projectPath 'builds/.gdignore') -Value ''
foreach ($engineArgs in @(
    ,@('--headless','--path',$projectPath,'--editor','--import','--quit'),
    ,@('--headless','--path',$projectPath,'--export-debug','Windows Desktop',(Join-Path $buildPath 'LankaRumble.exe'))
)) {
    $output = & $Godot @engineArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output | ForEach-Object { Write-Output $_ }
    if ($exitCode -ne 0 -or ($output -match 'SCRIPT ERROR:|ERROR:')) {
        throw "Windows build failed (exit $exitCode). Install matching 4.7.2 Standard export templates."
    }
}
Write-Output "Built $buildPath/LankaRumble.exe. Keep the .exe and .pck together."
