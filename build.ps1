param([string]$WindhawkPath = "$env:ProgramFiles\Windhawk")
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$config = Get-Content -LiteralPath (Join-Path $WindhawkPath 'windhawk.ini') -Raw
function Get-InstallPath([string]$key) {
    $match = [regex]::Match($config, "(?m)^$key=(.+)$")
    if (!$match.Success) { throw "Missing $key in windhawk.ini" }
    $value = [Environment]::ExpandEnvironmentVariables($match.Groups[1].Value.Trim())
    if ([IO.Path]::IsPathRooted($value)) { return $value }
    return Join-Path $WindhawkPath $value
}
$compiler = Get-InstallPath 'CompilerPath'
$engine = Get-InstallPath 'EnginePath'
$source = Get-Content -LiteralPath (Join-Path $root 'mod.wh.cpp') -Raw
$modId = [regex]::Match($source, '(?m)^// @id\s+(\S+)').Groups[1].Value
$version = [regex]::Match($source, '(?m)^// @version\s+(\S+)').Groups[1].Value
if (!$modId -or !$version) { throw 'Missing source metadata' }
New-Item -ItemType Directory -Force -Path (Join-Path $root 'build') | Out-Null
$flags = @(
    '-std=c++23', '-O2', '-shared', '-DUNICODE', '-D_UNICODE',
    '-DWINVER=0x0A00', '-D_WIN32_WINNT=0x0A00', '-D_WIN32_IE=0x0A00',
    '-DNTDDI_VERSION=0x0A000008', '-D__USE_MINGW_ANSI_STDIO=0', '-DWH_MOD',
    "-DWH_MOD_ID=L`"$modId`"", "-DWH_MOD_VERSION=L`"$version`"",
    "$engine\64\windhawk.lib", "$root\mod.wh.cpp",
    '-include', "$compiler\include\windhawk_api.h",
    '-target', 'x86_64-w64-mingw32', '-Wl,--export-all-symbols',
    '-ldwmapi', '-lgdi32', '-Wall', '-Wextra', '-Werror', '-o', "$root\build\rectangle-flick.dll"
)
& "$compiler\bin\clang++.exe" @flags
if ($LASTEXITCODE -ne 0) { throw "Compiler exited with $LASTEXITCODE" }
Write-Output 'Compiled build\rectangle-flick.dll with the installed Windhawk toolchain.'

