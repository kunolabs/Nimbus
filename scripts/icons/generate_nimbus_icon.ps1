param(
    [string] $RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..")).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function ConvertTo-Color {
    param([string] $Hex)
    return [System.Drawing.ColorTranslator]::FromHtml($Hex)
}

function New-RoundedRectPath {
    param(
        [single] $X,
        [single] $Y,
        [single] $Width,
        [single] $Height,
        [single] $Radius
    )

    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $Radius * 2
    $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
    $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
    $path.AddArc($X + $Width - $diameter, $Y + $Height - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-PointF {
    param([single] $X, [single] $Y)
    return [System.Drawing.PointF]::new($X, $Y)
}

function Draw-NimbusIcon {
    param(
        [ValidateSet("nimbus", "nimbus-playing", "nimbus-pausing", "nimbus-locked")]
        [string] $Variant,
        [int] $Size,
        [string] $OutputPath
    )

    $scale = [single]($Size / 256.0)
    function S {
        param([single] $Value)
        return [single]($Value * $scale)
    }

    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.Clear([System.Drawing.Color]::Transparent)

        $bounds = [System.Drawing.RectangleF]::new(0, 0, $Size, $Size)
        $backgroundPath = New-RoundedRectPath (S 8) (S 8) (S 240) (S 240) (S 48)
        $backgroundBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
            $bounds,
            (ConvertTo-Color "#07111f"),
            (ConvertTo-Color "#123a73"),
            45.0
        )
        $graphics.FillPath($backgroundBrush, $backgroundPath)

        $borderPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(95, 45, 212, 191), (S 3))
        $graphics.DrawPath($borderPen, $backgroundPath)

        $haloPath = [System.Drawing.Drawing2D.GraphicsPath]::new()
        $haloPath.AddBezier((S 55), (S 88), (S 91), (S 54), (S 135), (S 51), (S 172), (S 65))
        $haloPath.AddBezier((S 172), (S 65), (S 194), (S 73), (S 211), (S 88), (S 222), (S 104))

        $haloPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(220, 56, 189, 248), (S 10))
        $haloPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $haloPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $graphics.DrawPath($haloPen, $haloPath)

        $nShadowPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(92, 2, 8, 23), (S 28))
        $nShadowPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $nShadowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $nShadowPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawLine($nShadowPen, (S 84), (S 182), (S 84), (S 86))
        $graphics.DrawLine($nShadowPen, (S 84), (S 86), (S 174), (S 182))
        $graphics.DrawLine($nShadowPen, (S 174), (S 182), (S 174), (S 86))

        $nPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(252, 248, 250, 252), (S 25))
        $nPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $nPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $nPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        $graphics.DrawLine($nPen, (S 82), (S 178), (S 82), (S 82))
        $graphics.DrawLine($nPen, (S 82), (S 82), (S 174), (S 178))
        $graphics.DrawLine($nPen, (S 174), (S 178), (S 174), (S 82))

        $floorPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(225, 45, 212, 191), (S 8))
        $floorPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $floorPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $graphics.DrawLine($floorPen, (S 70), (S 205), (S 188), (S 205))

        if ($Variant -ne "nimbus") {
            $badgeBrushColor = switch ($Variant) {
                "nimbus-playing" { ConvertTo-Color "#22c55e" }
                "nimbus-pausing" { ConvertTo-Color "#f59e0b" }
                "nimbus-locked" { ConvertTo-Color "#8b5cf6" }
            }

            $badgeRect = [System.Drawing.RectangleF]::new((S 166), (S 166), (S 68), (S 68))
            $badgeBrush = [System.Drawing.SolidBrush]::new($badgeBrushColor)
            $badgeBorderPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(245, 248, 250, 252), (S 6))
            $graphics.FillEllipse($badgeBrush, $badgeRect)
            $graphics.DrawEllipse($badgeBorderPen, $badgeRect)

            $whiteBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
            $whitePen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, (S 7))
            $whitePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
            $whitePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

            switch ($Variant) {
                "nimbus-playing" {
                    [System.Drawing.PointF[]] $points = @(
                        (New-PointF (S 191) (S 182)),
                        (New-PointF (S 191) (S 218)),
                        (New-PointF (S 220) (S 200))
                    )
                    $graphics.FillPolygon($whiteBrush, $points)
                }
                "nimbus-pausing" {
                    $graphics.FillRectangle($whiteBrush, (S 185), (S 181), (S 10), (S 38))
                    $graphics.FillRectangle($whiteBrush, (S 207), (S 181), (S 10), (S 38))
                }
                "nimbus-locked" {
                    $graphics.DrawArc($whitePen, (S 184), (S 181), (S 31), (S 30), 200, 140)
                    $lockBody = New-RoundedRectPath (S 181) (S 197) (S 40) (S 28) (S 7)
                    $graphics.FillPath($whiteBrush, $lockBody)
                    $lockBody.Dispose()
                }
            }
        }

        $outputDirectory = Split-Path -Parent $OutputPath
        if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
            New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
        }
        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        if ($graphics) { $graphics.Dispose() }
        if ($bitmap) { $bitmap.Dispose() }
    }
}

function Save-Ico {
    param(
        [ValidateSet("nimbus", "nimbus-playing", "nimbus-pausing", "nimbus-locked")]
        [string] $Variant,
        [int[]] $Sizes,
        [string] $TempDir,
        [string] $OutputPath
    )

    $entries = foreach ($size in $Sizes) {
        $pngPath = Join-Path $TempDir "$Variant-$size.png"
        if (-not (Test-Path -LiteralPath $pngPath)) {
            throw "Missing generated PNG for ICO: $pngPath"
        }
        [PSCustomObject]@{
            Size = $size
            Bytes = [System.IO.File]::ReadAllBytes($pngPath)
        }
    }

    $outputDirectory = Split-Path -Parent $OutputPath
    if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
        New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
    }

    $stream = [System.IO.File]::Create($OutputPath)
    $writer = [System.IO.BinaryWriter]::new($stream)
    try {
        $writer.Write([UInt16] 0)
        $writer.Write([UInt16] 1)
        $writer.Write([UInt16] $entries.Count)

        $offset = 6 + (16 * $entries.Count)
        foreach ($entry in $entries) {
            $dimension = if ($entry.Size -ge 256) { 0 } else { $entry.Size }
            $writer.Write([byte] $dimension)
            $writer.Write([byte] $dimension)
            $writer.Write([byte] 0)
            $writer.Write([byte] 0)
            $writer.Write([UInt16] 1)
            $writer.Write([UInt16] 32)
            $writer.Write([UInt32] $entry.Bytes.Length)
            $writer.Write([UInt32] $offset)
            $offset += $entry.Bytes.Length
        }

        foreach ($entry in $entries) {
            $writer.Write($entry.Bytes)
        }
    }
    finally {
        $writer.Dispose()
        $stream.Dispose()
    }
}

$imageDir = Join-Path $RepoRoot "src_assets\common\assets\web\public\images"
$tempDir = Join-Path $RepoRoot "build\icon-gen\nimbus"
$sizes = @(16, 24, 32, 40, 45, 48, 64, 128, 256)
$icoSizes = @(16, 24, 32, 40, 48, 64, 128, 256)
$variants = @("nimbus", "nimbus-playing", "nimbus-pausing", "nimbus-locked")

New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

foreach ($variant in $variants) {
    foreach ($size in $sizes) {
        Draw-NimbusIcon -Variant $variant -Size $size -OutputPath (Join-Path $tempDir "$variant-$size.png")
    }

    Save-Ico -Variant $variant -Sizes $icoSizes -TempDir $tempDir -OutputPath (Join-Path $imageDir "$variant.ico")

    if ($variant -eq "nimbus") {
        Copy-Item -LiteralPath (Join-Path $tempDir "nimbus-256.png") -Destination (Join-Path $RepoRoot "nimbus.png") -Force
        Save-Ico -Variant $variant -Sizes $icoSizes -TempDir $tempDir -OutputPath (Join-Path $RepoRoot "nimbus.ico")
        Copy-Item -LiteralPath (Join-Path $tempDir "nimbus-45.png") -Destination (Join-Path $imageDir "logo-nimbus-45.png") -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "nimbus-16.png") -Destination (Join-Path $imageDir "logo-nimbus-16.png") -Force
    }
    else {
        Copy-Item -LiteralPath (Join-Path $tempDir "$variant-256.png") -Destination (Join-Path $imageDir "$variant.png") -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "$variant-45.png") -Destination (Join-Path $imageDir "$variant-45.png") -Force
        Copy-Item -LiteralPath (Join-Path $tempDir "$variant-16.png") -Destination (Join-Path $imageDir "$variant-16.png") -Force
    }
}

Write-Host "Generated Nimbus icon assets under $imageDir"
Write-Host "Generated Windows product icon at $(Join-Path $RepoRoot "nimbus.ico")"
