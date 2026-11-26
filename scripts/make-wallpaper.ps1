# Generates the default wallpaper (procedural, no external assets) and then
# runs the shared asset pipeline (wallpaper.jpg / wallpaper-blur.jpg / icons).
#
#   pwsh -File scripts/make-wallpaper.ps1
param(
  [string]$OutDir = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$W = 2560
$H = 1440
$rect = New-Object System.Drawing.Rectangle 0, 0, $W, $H

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# base: dusk blue -> indigo -> deep teal
$base = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $rect,
  [System.Drawing.Color]::FromArgb(255, 8, 14, 36),
  [System.Drawing.Color]::FromArgb(255, 4, 30, 32),
  35.0
)
$blend = New-Object System.Drawing.Drawing2D.ColorBlend(3)
$blend.Colors = @(
  [System.Drawing.Color]::FromArgb(255, 16, 26, 66),
  [System.Drawing.Color]::FromArgb(255, 44, 22, 74),
  [System.Drawing.Color]::FromArgb(255, 6, 44, 52)
)
$blend.Positions = @(0.0, 0.5, 1.0)
$base.InterpolationColors = $blend
$g.FillRectangle($base, $rect)
$base.Dispose()

function Draw-Blob([double]$cx, [double]$cy, [double]$rx, [double]$ry, [System.Drawing.Color]$color) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse([single]($cx - $rx), [single]($cy - $ry), [single]($rx * 2), [single]($ry * 2))
  $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
  $brush.CenterColor = $color
  $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, $color))
  $brush.CenterPoint = New-Object System.Drawing.PointF([single]$cx, [single]$cy)
  $g.FillPath($brush, $path)
  $brush.Dispose()
  $path.Dispose()
}

Draw-Blob ($W * 0.16) ($H * 0.22) ($W * 0.34) ($H * 0.42) ([System.Drawing.Color]::FromArgb(225, 70, 120, 255))
Draw-Blob ($W * 0.85) ($H * 0.12) ($W * 0.28) ($H * 0.36) ([System.Drawing.Color]::FromArgb(200, 168, 84, 230))
Draw-Blob ($W * 0.64) ($H * 0.92) ($W * 0.36) ($H * 0.40) ([System.Drawing.Color]::FromArgb(205, 38, 210, 190))
Draw-Blob ($W * 0.30) ($H * 0.95) ($W * 0.26) ($H * 0.30) ([System.Drawing.Color]::FromArgb(185, 255, 148, 92))
Draw-Blob ($W * 0.52) ($H * 0.55) ($W * 0.18) ($H * 0.22) ([System.Drawing.Color]::FromArgb(90, 120, 200, 255))

# grain
$rand = New-Object System.Random 20261126
$noise = New-Object System.Drawing.Bitmap($W, $H)
for ($y = 0; $y -lt $H; $y += 3) {
  for ($x = 0; $x -lt $W; $x += 3) {
    $v = $rand.Next(0, 30)
    $noise.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(16, $v, $v, $v))
  }
}
$g.DrawImage($noise, 0, 0, $W, $H)
$noise.Dispose()

# vignette
$vignette = New-Object System.Drawing.Drawing2D.GraphicsPath
$vignette.AddEllipse([single](-$W * 0.2), [single](-$H * 0.3), [single]($W * 1.4), [single]($H * 1.6))
$vg = New-Object System.Drawing.Drawing2D.PathGradientBrush($vignette)
$vg.CenterColor = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
$vg.SurroundColors = @([System.Drawing.Color]::FromArgb(150, 2, 4, 10))
$vg.CenterPoint = New-Object System.Drawing.PointF([single]($W / 2), [single]($H / 2))
$g.FillRectangle($vg, $rect)
$vg.Dispose()
$vignette.Dispose()
$g.Dispose()

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) 'acrylic-wallpaper-raw.png'
$bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

& (Join-Path $PSScriptRoot 'make-assets.ps1') -Source $tmp -OutDir $OutDir
Remove-Item -LiteralPath $tmp -Force
