# Turns any picture into the extension's assets:
#   wallpaper.jpg      2560 px wide, JPEG q88
#   wallpaper-blur.jpg 1280 px wide, pre-blurred (downscale -> upscale), q82
#   icons/icon{16,32,48,128}.png  rounded crop of the same picture
#
# Usage:
#   pwsh -File scripts/make-assets.ps1 -Source "D:\pictures\wall.jpg"
param(
  [Parameter(Mandatory = $true)][string]$Source,
  [string]$OutDir = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

if (-not (Test-Path -LiteralPath $Source)) { throw "image not found: $Source" }

$img = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $Source).Path)
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }

function Save-Jpeg([System.Drawing.Bitmap]$image, [string]$path, [int]$quality) {
  $eps = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
  $image.Save($path, $enc, $eps)
}

function Resize-Image([System.Drawing.Image]$image, [int]$w, [int]$h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.DrawImage($image, 0, 0, $w, $h)
  $g.Dispose()
  return $bmp
}

# 1) sharp version, 2560 wide
$w = 2560
$h = [int][Math]::Max(1, [Math]::Round($w * $img.Height / $img.Width))
$sharp = Resize-Image $img $w $h
Save-Jpeg $sharp (Join-Path $OutDir 'wallpaper.jpg') 88
$sharp.Dispose()

# 2) pre-blurred version: crush it down, blow it back up
$tinyW = 48
$tinyH = [int][Math]::Max(1, [Math]::Round($tinyW * $img.Height / $img.Width))
$tiny = Resize-Image $img $tinyW $tinyH
$blurW = 1280
$blurH = [int][Math]::Max(1, [Math]::Round($blurW * $img.Height / $img.Width))
$blur = Resize-Image $tiny $blurW $blurH
Save-Jpeg $blur (Join-Path $OutDir 'wallpaper-blur.jpg') 82
$blur.Dispose()
$tiny.Dispose()

# 3) icons
$side = [Math]::Min($img.Width, $img.Height)
$srcRect = New-Object System.Drawing.Rectangle ([int](($img.Width - $side) / 2)), ([int](($img.Height - $side) / 2)), $side, $side
$iconDir = Join-Path $OutDir 'icons'
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null
foreach ($size in 16, 32, 48, 128) {
  $icon = New-Object System.Drawing.Bitmap($size, $size)
  $ig = [System.Drawing.Graphics]::FromImage($icon)
  $ig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $ig.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $ig.Clear([System.Drawing.Color]::Transparent)
  $radius = [int][Math]::Max(2, $size * 0.22)
  $d = $radius * 2
  $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
  $clip.AddArc(0, 0, $d, $d, 180, 90)
  $clip.AddArc($size - $d, 0, $d, $d, 270, 90)
  $clip.AddArc($size - $d, $size - $d, $d, $d, 0, 90)
  $clip.AddArc(0, $size - $d, $d, $d, 90, 90)
  $clip.CloseFigure()
  $ig.SetClip($clip)
  $dest = New-Object System.Drawing.Rectangle 0, 0, $size, $size
  $ig.DrawImage($img, $dest, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
  $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(72, 255, 255, 255))
  $inset = [int][Math]::Max(2, $size * 0.18)
  $ig.FillRectangle($brush, $inset, [int]($size * 0.42), $size - 2 * $inset, [int]($size * 0.34))
  $brush.Dispose()
  $ig.Dispose()
  $clip.Dispose()
  $icon.Save((Join-Path $iconDir ("icon{0}.png" -f $size)), [System.Drawing.Imaging.ImageFormat]::Png)
  $icon.Dispose()
}
$img.Dispose()

Write-Output ('wallpaper.jpg:      ' + (Get-Item (Join-Path $OutDir 'wallpaper.jpg')).Length + ' bytes')
Write-Output ('wallpaper-blur.jpg: ' + (Get-Item (Join-Path $OutDir 'wallpaper-blur.jpg')).Length + ' bytes')
