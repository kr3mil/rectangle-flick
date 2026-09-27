param([string]$WindhawkPath = "$env:ProgramFiles\Windhawk")
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
New-Item -ItemType Directory -Force -Path "$root\build" | Out-Null
& (Join-Path $WindhawkPath 'Compiler\bin\clang++.exe') `
    -std=c++23 -O2 -static -DUNICODE -D_UNICODE -D_WIN32_WINNT=0x0A00 -DWINVER=0x0A00 `
    "$root\tests\geometry.cpp" -ldwmapi -lgdi32 -o "$root\build\geometry-tests.exe"
if ($LASTEXITCODE -ne 0) { throw "Test compilation failed: $LASTEXITCODE" }
& "$root\build\geometry-tests.exe"
if ($LASTEXITCODE -ne 0) { throw "Geometry tests failed: $LASTEXITCODE" }

