param([string]$WindhawkPath = "$env:ProgramFiles\Windhawk")
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$sourcePath = Join-Path $root 'mod.wh.cpp'
$source = Get-Content -LiteralPath $sourcePath -Raw
function Metadata([string]$name) {
    return [regex]::Match($source, "(?m)^// @$name\s+([^\r\n]+)").Groups[1].Value.Trim()
}
$modId = Metadata 'id'
$version = Metadata 'version'
$github = Metadata 'github'
if ($modId -notmatch '^[a-z0-9-]+$') { throw 'Invalid mod ID' }
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'A semantic release version is required' }
if ($github -notmatch '^https://github\.com/[a-zA-Z0-9-]+/?$') {
    throw 'Add the submitting author profile as // @github https://github.com/USERNAME before packaging.'
}
if ((Metadata 'license') -ne 'MIT') { throw 'Review license metadata before packaging' }
if ($source -match '(?i)\bMVP\b') { throw 'Remove obsolete MVP wording before packaging' }
& (Join-Path $root 'build.ps1') -WindhawkPath $WindhawkPath
& (Join-Path $root 'test.ps1') -WindhawkPath $WindhawkPath
$destination = Join-Path $root "release\$modId-$version\mods"
New-Item -ItemType Directory -Path $destination -Force | Out-Null
$artifact = Join-Path $destination "$modId.wh.cpp"
Copy-Item -LiteralPath $sourcePath -Destination $artifact -Force
$hash = (Get-FileHash -LiteralPath $artifact -Algorithm SHA256).Hash
"$hash  mods/$modId.wh.cpp" | Set-Content -LiteralPath (Join-Path (Split-Path $destination) 'SHA256SUMS.txt')
Write-Output "Submission source: $artifact"
Write-Output "Submit only mods/$modId.wh.cpp to the Windhawk collection. Author: $github"
