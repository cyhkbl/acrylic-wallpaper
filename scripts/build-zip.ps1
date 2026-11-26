# Builds dist/acrylic-wallpaper-<version>.zip with only the files the browser
# needs (store upload uses the same archive).
param(
  [string]$OutDir = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
$OutDir = (Resolve-Path $OutDir).Path
$manifest = Get-Content -LiteralPath (Join-Path $OutDir 'manifest.json') -Raw | ConvertFrom-Json
$version = $manifest.version
$dist = Join-Path $OutDir 'dist'
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$zip = Join-Path $dist ("acrylic-wallpaper-{0}.zip" -f $version)
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }

$files = @(
  'manifest.json',
  'newtab.html',
  'newtab.css',
  'content.js',
  'popup.html',
  'popup.css',
  'popup.js',
  'wallpaper.jpg',
  'wallpaper-blur.jpg'
)
$staging = Join-Path ([System.IO.Path]::GetTempPath()) ("acrylic-build-" + [guid]::NewGuid().ToString('n'))
New-Item -ItemType Directory -Force -Path $staging | Out-Null
foreach ($f in $files) { Copy-Item -LiteralPath (Join-Path $OutDir $f) -Destination $staging }
Copy-Item -LiteralPath (Join-Path $OutDir 'icons') -Destination $staging -Recurse

Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zip -CompressionLevel Optimal
Remove-Item -LiteralPath $staging -Recurse -Force

Write-Output ("built {0} ({1} KB)" -f $zip, [math]::Round((Get-Item $zip).Length / 1KB, 1))
