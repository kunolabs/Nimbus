#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$SourceConfigDir = "",
    [string]$NimbusConfigDir = "",
    [string]$OutputDir = "",
    [switch]$ImportToNimbus,
    [switch]$SkipCredentials,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ExportFiles = @(
    "apps.json",
    "sunshine.conf",
    "sunshine_state.json",
    "vibeshine_state.json",
    "virtual_display_cache.json",
    "nvprefs_undo.json"
)

$ImportFiles = @(
    "apps.json",
    "sunshine.conf",
    "sunshine_state.json",
    "vibeshine_state.json"
)

$ExportDirectories = @("covers")
$ImportDirectories = @("covers")
if (-not $SkipCredentials) {
    $ExportDirectories += "credentials"
    $ImportDirectories += "credentials"
}

function Get-InstallLocationsFromRegistry {
    param([string]$NamePattern)

    $roots = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($root in $roots) {
        Get-ItemProperty -Path $root -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -match $NamePattern } |
            ForEach-Object {
                [PSCustomObject]@{
                    DisplayName = $_.DisplayName
                    InstallLocation = $_.InstallLocation
                }
            }
    }
}

function Test-ConfigCandidate {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $false
    }

    try {
        if (-not (Test-Path -LiteralPath $Path -PathType Container -ErrorAction Stop)) {
            return $false
        }
    }
    catch {
        return $false
    }

    foreach ($name in @("apps.json", "sunshine.conf", "sunshine_state.json", "credentials", "covers")) {
        try {
            if (Test-Path -LiteralPath (Join-Path $Path $name) -ErrorAction Stop) {
                return $true
            }
        }
        catch {
            continue
        }
    }

    return $false
}

function Get-DriveRootProductCandidates {
    param([string[]]$ProductNames)

    Get-PSDrive -PSProvider FileSystem |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.Root) } |
        ForEach-Object {
            foreach ($productName in $ProductNames) {
                Join-Path $_.Root $productName
            }
        }
}

function Resolve-ConfigDirectory {
    param(
        [string]$ExplicitPath,
        [string]$ProductPattern,
        [string[]]$FallbackRoots
    )

    $candidates = New-Object System.Collections.Generic.List[string]

    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        $candidates.Add($ExplicitPath)
    }

    Get-InstallLocationsFromRegistry -NamePattern $ProductPattern |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_.InstallLocation) } |
        ForEach-Object { $candidates.Add($_.InstallLocation) }

    foreach ($root in $FallbackRoots) {
        if (-not [string]::IsNullOrWhiteSpace($root)) {
            $candidates.Add($root)
        }
    }

    foreach ($candidate in $candidates | Select-Object -Unique) {
        $expanded = [Environment]::ExpandEnvironmentVariables($candidate.Trim().Trim('"'))
        $configChild = Join-Path $expanded "config"
        if (Test-ConfigCandidate -Path $configChild) {
            return (Resolve-Path -LiteralPath $configChild).ProviderPath
        }
        if (Test-ConfigCandidate -Path $expanded) {
            return (Resolve-Path -LiteralPath $expanded).ProviderPath
        }
    }

    return ""
}

function Copy-KnownItem {
    param(
        [string]$Source,
        [string]$Destination,
        [bool]$Overwrite
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        return "missing"
    }

    if ((Test-Path -LiteralPath $Destination) -and -not $Overwrite) {
        return "skipped-existing"
    }

    if (Test-Path -LiteralPath $Destination) {
        if ($PSCmdlet.ShouldProcess($Destination, "replace existing item")) {
            Remove-Item -LiteralPath $Destination -Recurse -Force
        }
    }

    $destinationParent = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $destinationParent)) {
        New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($Destination, "copy from $Source")) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
    }

    return "copied"
}

function Get-FileInventory {
    param([string]$Root)

    if (-not (Test-Path -LiteralPath $Root)) {
        return @()
    }

    Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            $relative = $_.FullName.Substring($Root.Length).TrimStart("\", "/")
            $hash = Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
            [PSCustomObject]@{
                Path = $relative
                Length = $_.Length
                Sha256 = $hash.Hash
            }
        }
}

function Repair-CredentialsAcl {
    param([string]$ConfigDir)

    $credentialsDir = Join-Path $ConfigDir "credentials"
    if (-not (Test-Path -LiteralPath $credentialsDir -PathType Container)) {
        return
    }

    $icacls = Join-Path $env:SystemRoot "System32\icacls.exe"
    & $icacls $credentialsDir "/inheritance:r" | Out-Null
    & $icacls $credentialsDir "/grant:r" "*S-1-5-18:(OI)(CI)(F)" | Out-Null
    & $icacls $credentialsDir "/grant:r" "*S-1-5-32-544:(OI)(CI)(F)" | Out-Null
    & $icacls $credentialsDir "/grant:r" "*S-1-5-32-545:(R)" | Out-Null
}

function Rewrite-AppImagePathsForNimbus {
    param(
        [string]$AppsJsonPath,
        [string]$NimbusConfigDir
    )

    if (-not (Test-Path -LiteralPath $AppsJsonPath -PathType Leaf)) {
        return "missing"
    }

    $targetCoversDir = Join-Path $NimbusConfigDir "covers"
    $appsDocument = Get-Content -LiteralPath $AppsJsonPath -Raw | ConvertFrom-Json
    $rewritten = 0

    foreach ($app in @($appsDocument.apps)) {
        $imagePathProperty = $app.PSObject.Properties["image-path"]
        if ($null -eq $imagePathProperty) {
            continue
        }

        $imagePath = [string]$imagePathProperty.Value
        if ([string]::IsNullOrWhiteSpace($imagePath) -or -not [System.IO.Path]::IsPathRooted($imagePath)) {
            continue
        }

        $normalizedImagePath = $imagePath.Replace("/", "\")
        $coversMarker = "\covers\"
        $coversIndex = $normalizedImagePath.IndexOf($coversMarker, [StringComparison]::OrdinalIgnoreCase)
        if ($coversIndex -lt 0) {
            continue
        }

        $relativeCoverPath = $normalizedImagePath.Substring($coversIndex + $coversMarker.Length)
        if ([string]::IsNullOrWhiteSpace($relativeCoverPath)) {
            continue
        }

        $imagePathProperty.Value = Join-Path $targetCoversDir $relativeCoverPath
        $rewritten++
    }

    if ($rewritten -gt 0) {
        $appsDocument |
            ConvertTo-Json -Depth 32 |
            Set-Content -LiteralPath $AppsJsonPath -Encoding UTF8
        return "rewritten-$rewritten"
    }

    return "unchanged"
}

$apolloFallbackRoots = @(
    "$env:ProgramFiles\Apollo",
    "${env:ProgramFiles(x86)}\Apollo",
    "$env:ProgramData\Apollo",
    "$env:LOCALAPPDATA\Apollo",
    "$env:APPDATA\Apollo"
)
$apolloFallbackRoots += Get-DriveRootProductCandidates -ProductNames @("Apollo")

$sourceConfig = Resolve-ConfigDirectory `
    -ExplicitPath $SourceConfigDir `
    -ProductPattern "Apollo" `
    -FallbackRoots $apolloFallbackRoots

if ([string]::IsNullOrWhiteSpace($sourceConfig)) {
    throw "Apollo config directory was not found. Pass -SourceConfigDir with the Apollo config path or an exported bundle config path."
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path (Get-Location) "nimbus-switch-bundles\$timestamp-apollo-to-nimbus"
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$resolvedOutput = (Resolve-Path -LiteralPath $OutputDir).ProviderPath
$bundleConfig = Join-Path $resolvedOutput "config"
New-Item -ItemType Directory -Path $bundleConfig -Force | Out-Null

$actions = New-Object System.Collections.Generic.List[object]

foreach ($name in $ExportFiles) {
    $source = Join-Path $sourceConfig $name
    $destination = Join-Path $bundleConfig $name
    $status = Copy-KnownItem -Source $source -Destination $destination -Overwrite $true
    $actions.Add([PSCustomObject]@{
        Phase = "export"
        Item = $name
        Source = $source
        Destination = $destination
        Status = $status
    })
}

foreach ($name in $ExportDirectories) {
    $source = Join-Path $sourceConfig $name
    $destination = Join-Path $bundleConfig $name
    $status = Copy-KnownItem -Source $source -Destination $destination -Overwrite $true
    $actions.Add([PSCustomObject]@{
        Phase = "export"
        Item = $name
        Source = $source
        Destination = $destination
        Status = $status
    })
}

$nimbusConfig = ""
if ($ImportToNimbus) {
    $nimbusFallbackRoots = @(
        "$env:ProgramFiles\Nimbus",
        "${env:ProgramFiles(x86)}\Nimbus",
        "$env:ProgramData\Nimbus",
        "$env:LOCALAPPDATA\Nimbus",
        "$env:APPDATA\Nimbus"
    )

    $nimbusConfig = Resolve-ConfigDirectory `
        -ExplicitPath $NimbusConfigDir `
        -ProductPattern "Nimbus|Vibepollo" `
        -FallbackRoots $nimbusFallbackRoots

    if ([string]::IsNullOrWhiteSpace($nimbusConfig)) {
        if ([string]::IsNullOrWhiteSpace($NimbusConfigDir)) {
            $nimbusConfig = Join-Path $env:ProgramFiles "Nimbus\config"
        } else {
            $nimbusConfig = $NimbusConfigDir
        }
    }

    New-Item -ItemType Directory -Path $nimbusConfig -Force | Out-Null
    $nimbusConfig = (Resolve-Path -LiteralPath $nimbusConfig).ProviderPath

    $targetBackup = Join-Path $resolvedOutput "existing-nimbus-backup"
    New-Item -ItemType Directory -Path $targetBackup -Force | Out-Null

    foreach ($name in ($ImportFiles + $ImportDirectories)) {
        $existingTarget = Join-Path $nimbusConfig $name
        if (Test-Path -LiteralPath $existingTarget) {
            $backupDestination = Join-Path $targetBackup $name
            $backupStatus = Copy-KnownItem -Source $existingTarget -Destination $backupDestination -Overwrite $true
            $actions.Add([PSCustomObject]@{
                Phase = "target-backup"
                Item = $name
                Source = $existingTarget
                Destination = $backupDestination
                Status = $backupStatus
            })
        }
    }

    foreach ($name in $ImportFiles) {
        $source = Join-Path $bundleConfig $name
        $destination = Join-Path $nimbusConfig $name
        $status = Copy-KnownItem -Source $source -Destination $destination -Overwrite ([bool]$Force)
        $actions.Add([PSCustomObject]@{
            Phase = "import"
            Item = $name
            Source = $source
            Destination = $destination
            Status = $status
        })
    }

    foreach ($name in $ImportDirectories) {
        $source = Join-Path $bundleConfig $name
        $destination = Join-Path $nimbusConfig $name
        $status = Copy-KnownItem -Source $source -Destination $destination -Overwrite ([bool]$Force)
        $actions.Add([PSCustomObject]@{
            Phase = "import"
            Item = $name
            Source = $source
            Destination = $destination
            Status = $status
        })
    }

    $appsJsonPath = Join-Path $nimbusConfig "apps.json"
    $rewriteStatus = Rewrite-AppImagePathsForNimbus -AppsJsonPath $appsJsonPath -NimbusConfigDir $nimbusConfig
    $actions.Add([PSCustomObject]@{
        Phase = "import-postprocess"
        Item = "apps.json image paths"
        Source = $appsJsonPath
        Destination = $appsJsonPath
        Status = $rewriteStatus
    })

    if (-not $SkipCredentials) {
        Repair-CredentialsAcl -ConfigDir $nimbusConfig
    }
}

$manifest = [PSCustomObject]@{
    Schema = "nimbus.apolloSwitchBundle.v1"
    CapturedAt = (Get-Date).ToString("o")
    SourceConfigDir = $sourceConfig
    BundleDir = $resolvedOutput
    BundleConfigDir = $bundleConfig
    ImportToNimbus = [bool]$ImportToNimbus
    NimbusConfigDir = $nimbusConfig
    SkipCredentials = [bool]$SkipCredentials
    Force = [bool]$Force
    Sensitive = -not $SkipCredentials
    Actions = @($actions.ToArray())
    BundleInventory = @(Get-FileInventory -Root $bundleConfig)
}

$manifestPath = Join-Path $resolvedOutput "switch-bundle-manifest.json"
$summaryPath = Join-Path $resolvedOutput "switch-bundle-summary.md"

$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

$copied = @($actions | Where-Object { $_.Status -eq "copied" }).Count
$skipped = @($actions | Where-Object { $_.Status -like "skipped*" }).Count
$missing = @($actions | Where-Object { $_.Status -eq "missing" }).Count

$summary = @(
    "# Apollo To Nimbus Switch Bundle"
    ""
    "- Captured: $($manifest.CapturedAt)"
    "- Source config: $sourceConfig"
    "- Bundle: $resolvedOutput"
    "- Imported to Nimbus: $([bool]$ImportToNimbus)"
    "- Nimbus config: $nimbusConfig"
    "- Includes credentials: $(-not $SkipCredentials)"
    "- Copied: $copied"
    "- Skipped: $skipped"
    "- Missing: $missing"
    ""
    "This bundle may contain web UI credentials, paired-client state, private keys, and client certificates."
    "Do not attach it to public issues or share it without reviewing the contents first."
    ""
    "Machine-readable manifest: switch-bundle-manifest.json"
) -join [Environment]::NewLine

$summary | Set-Content -LiteralPath $summaryPath -Encoding UTF8

Write-Host "Apollo to Nimbus switch bundle written to:"
Write-Host "  $summaryPath"
Write-Host "  $manifestPath"
if ($ImportToNimbus) {
    Write-Host "Import target:"
    Write-Host "  $nimbusConfig"
}
