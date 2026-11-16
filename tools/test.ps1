param(
    [Parameter(Mandatory=$true)][string]$Godot
)
$ErrorActionPreference = 'Stop'
$projectPath = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Godot = (Resolve-Path -LiteralPath $Godot).Path
$resultsPath = Join-Path $projectPath 'builds/test-results'
New-Item -ItemType Directory -Force $resultsPath | Out-Null
Set-Content -LiteralPath (Join-Path $projectPath 'builds/.gdignore') -Value ''
function Invoke-EngineCheck([string]$Name, [string[]]$EngineArgs) {
    $outputPath = Join-Path $resultsPath "$Name.txt"
    $output = & $Godot @EngineArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output | Set-Content -LiteralPath $outputPath -Encoding utf8
    $output | ForEach-Object { Write-Output $_ }
    if ($exitCode -ne 0 -or ($output -match 'SCRIPT ERROR:|ERROR:|instances were leaked')) {
        throw "$Name failed; exit $exitCode. See $outputPath"
    }
}
Invoke-EngineCheck 'import' @('--headless','--path',$projectPath,'--editor','--import','--quit')
Invoke-EngineCheck 'combat' @('--headless','--path',$projectPath,'--script','res://tests/run_tests.gd')
Invoke-EngineCheck 'throws' @('--headless','--path',$projectPath,'--script','res://tests/run_throw_tests.gd')
Invoke-EngineCheck 'scenes' @('--headless','--fixed-fps','60','--max-fps','0','--path',$projectPath,'--script','res://tests/run_scene_tests.gd')
Write-Output "All checks passed. Logs: $resultsPath"
