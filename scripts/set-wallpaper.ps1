# Replace the bundled wallpaper with your own picture.
#
#   pwsh -File scripts/set-wallpaper.ps1 -Image "D:\pictures\wall.jpg"
#
# Produces wallpaper.jpg (2560 wide), wallpaper-blur.jpg (pre-blurred 1280) and
# the icon set, then you reload the extension from the extensions page.
param(
  [Parameter(Mandatory = $true)][string]$Image
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'make-assets.ps1') -Source $Image
Write-Output 'Done. Reload the extension from edge://extensions (or chrome://extensions).'
