#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$InstallerPath = "",
    [string]$OutputDir = "",
    [ValidateSet("preinstall", "postinstall", "postuninstall", "upgrade", "custom")]
    [string]$Stage = "custom",
    [string]$WebUiUrl = "https://localhost:47990",
    [switch]$SkipWebUiProbe,
    [string]$Notes = ""
)

$ErrorActionPreference = "Stop"

function New-SafeName([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "custom"
    }

    return ($Value -replace '[^0-9A-Za-z._-]', '-').Trim("-")
}

function ConvertTo-PlainObject($Value) {
    if ($null -eq $Value) {
        return $null
    }

    if ($Value -is [System.Array]) {
        return @($Value | ForEach-Object { ConvertTo-PlainObject $_ })
    }

    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        return $Value
    }

    return $Value
}

function Write-JsonFile([string]$Path, $Value) {
    $plain = ConvertTo-PlainObject $Value
    $plain | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-RegistryUninstallEntries {
    $roots = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($root in $roots) {
        Get-ItemProperty -Path $root -ErrorAction SilentlyContinue |
            Where-Object {
                $_.DisplayName -match "Nimbus|Apollo|Vibepollo|Sunshine|Vibeshine"
            } |
            Select-Object `
                @{Name = "RegistryPath"; Expression = { $_.PSPath } },
                DisplayName,
                DisplayVersion,
                Publisher,
                InstallLocation,
                InstallSource,
                UninstallString,
                QuietUninstallString,
                URLInfoAbout,
                HelpLink
    }
}

function Get-RelatedServices {
    Get-Service -Name "*Nimbus*", "*Apollo*", "*Sunshine*", "*Vibeshine*", "*Vibepollo*" -ErrorAction SilentlyContinue |
        Sort-Object Name |
        Select-Object Name, DisplayName, Status, StartType, ServiceType, CanStop
}

function Get-RelatedProcesses {
    Get-Process -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ProcessName -match "Nimbus|Apollo|Sunshine|Vibepollo|Vibeshine"
        } |
        Sort-Object ProcessName |
        Select-Object ProcessName, Id, Path, StartTime
}

function Get-RelatedShortcuts {
    $paths = @(
        [Environment]::GetFolderPath("CommonPrograms"),
        [Environment]::GetFolderPath("Programs"),
        [Environment]::GetFolderPath("CommonDesktopDirectory"),
        [Environment]::GetFolderPath("DesktopDirectory")
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        Get-ChildItem -LiteralPath $path -Recurse -Filter "*.lnk" -ErrorAction SilentlyContinue |
            Where-Object {
                $_.FullName -match "Nimbus|Apollo|Sunshine|Vibepollo|Vibeshine" -or $_.Name -match "Nimbus|Apollo|Sunshine|Vibepollo|Vibeshine"
            } |
            Select-Object Name, FullName, Length, LastWriteTime
    }
}

function Get-RelatedPaths {
    $candidates = @(
        "$env:ProgramFiles\Nimbus",
        "$env:ProgramFiles\Apollo",
        "$env:ProgramFiles\Sunshine",
        "$env:ProgramFiles\Vibepollo",
        "$env:ProgramFiles\Vibeshine",
        "${env:ProgramFiles(x86)}\Nimbus",
        "${env:ProgramFiles(x86)}\Apollo",
        "${env:ProgramFiles(x86)}\Sunshine",
        "${env:ProgramFiles(x86)}\Vibepollo",
        "${env:ProgramFiles(x86)}\Vibeshine",
        "$env:ProgramData\Nimbus",
        "$env:ProgramData\Apollo",
        "$env:ProgramData\Sunshine",
        "$env:ProgramData\Vibepollo",
        "$env:ProgramData\Vibeshine",
        "$env:LOCALAPPDATA\Nimbus",
        "$env:LOCALAPPDATA\Apollo",
        "$env:LOCALAPPDATA\Sunshine",
        "$env:LOCALAPPDATA\Vibepollo",
        "$env:LOCALAPPDATA\Vibeshine",
        "$env:APPDATA\Nimbus",
        "$env:APPDATA\Apollo",
        "$env:APPDATA\Sunshine",
        "$env:APPDATA\Vibepollo",
        "$env:APPDATA\Vibeshine"
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($candidate in $candidates) {
        [PSCustomObject]@{
            Path = $candidate
            Exists = Test-Path -LiteralPath $candidate
        }
    }
}

function Get-ListeningPorts {
    $ports = @(47984, 47989, 47990, 48010, 5353)
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Where-Object { $_.LocalPort -in $ports } |
        Sort-Object LocalPort |
        Select-Object LocalAddress, LocalPort, OwningProcess, State
}

function Test-WebUi([string]$Url) {
    if ([string]::IsNullOrWhiteSpace($Url)) {
        return [PSCustomObject]@{
            Url = $Url
            Skipped = $true
            Status = "Skipped"
            Error = "No URL was provided."
        }
    }

    $oldCertificateValidationCallback = [Net.ServicePointManager]::ServerCertificateValidationCallback
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        [Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 8 -ErrorAction Stop
        return [PSCustomObject]@{
            Url = $Url
            Skipped = $false
            Status = "Reachable"
            StatusCode = [int]$response.StatusCode
            ContentLength = $response.RawContentLength
        }
    } catch {
        return [PSCustomObject]@{
            Url = $Url
            Skipped = $false
            Status = "Failed"
            Error = $_.Exception.Message
        }
    } finally {
        [Net.ServicePointManager]::ServerCertificateValidationCallback = $oldCertificateValidationCallback
    }
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$safeStage = New-SafeName $Stage
if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path (Get-Location) ("nimbus-fixture-evidence\$timestamp-$safeStage")
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$resolvedOutputDir = (Resolve-Path -LiteralPath $OutputDir).ProviderPath

$installerEvidence = $null
if (-not [string]::IsNullOrWhiteSpace($InstallerPath)) {
    if (Test-Path -LiteralPath $InstallerPath) {
        $resolvedInstaller = (Resolve-Path -LiteralPath $InstallerPath).ProviderPath
        $signature = Get-AuthenticodeSignature -LiteralPath $resolvedInstaller
        $installerEvidence = [PSCustomObject]@{
            Path = $resolvedInstaller
            Length = (Get-Item -LiteralPath $resolvedInstaller).Length
            Sha256 = (Get-FileHash -LiteralPath $resolvedInstaller -Algorithm SHA256).Hash
            SignatureStatus = $signature.Status.ToString()
            SignatureStatusMessage = $signature.StatusMessage
            SignerCertificateSubject = if ($signature.SignerCertificate) { $signature.SignerCertificate.Subject } else { "" }
            SignerCertificateThumbprint = if ($signature.SignerCertificate) { $signature.SignerCertificate.Thumbprint } else { "" }
        }
    } else {
        $installerEvidence = [PSCustomObject]@{
            Path = $InstallerPath
            Error = "InstallerPath does not exist."
        }
    }
}

$computerInfo = Get-ComputerInfo -Property `
    CsName,
    WindowsProductName,
    WindowsVersion,
    OsBuildNumber,
    OsHardwareAbstractionLayer,
    CsManufacturer,
    CsModel,
    CsProcessors,
    CsTotalPhysicalMemory,
    HyperVisorPresent,
    DeviceGuardVirtualizationBasedSecurityStatus -ErrorAction SilentlyContinue

$evidence = [PSCustomObject]@{
    Schema = "nimbus.windowsInstallerFixture.v1"
    CapturedAt = (Get-Date).ToString("o")
    Stage = $Stage
    Notes = $Notes
    Installer = $installerEvidence
    Computer = $computerInfo
    Services = @(Get-RelatedServices)
    Processes = @(Get-RelatedProcesses)
    UninstallEntries = @(Get-RegistryUninstallEntries)
    Shortcuts = @(Get-RelatedShortcuts)
    RelatedPaths = @(Get-RelatedPaths)
    ListeningPorts = @(Get-ListeningPorts)
    WebUi = if ($SkipWebUiProbe) {
        [PSCustomObject]@{
            Url = $WebUiUrl
            Skipped = $true
            Status = "Skipped"
            Error = ""
        }
    } else {
        Test-WebUi -Url $WebUiUrl
    }
}

$jsonPath = Join-Path $resolvedOutputDir "fixture-evidence.json"
$summaryPath = Join-Path $resolvedOutputDir "fixture-summary.md"

Write-JsonFile -Path $jsonPath -Value $evidence

$serviceSummary = if ($evidence.Services.Count -gt 0) {
    ($evidence.Services | ForEach-Object { "- $($_.Name): $($_.Status) / $($_.StartType)" }) -join [Environment]::NewLine
} else {
    "- None found"
}

$uninstallSummary = if ($evidence.UninstallEntries.Count -gt 0) {
    ($evidence.UninstallEntries | ForEach-Object { "- $($_.DisplayName) $($_.DisplayVersion) / $($_.Publisher)" }) -join [Environment]::NewLine
} else {
    "- None found"
}

$installerSummary = if ($null -ne $installerEvidence -and -not $installerEvidence.PSObject.Properties["Error"]) {
    @(
        "- Path: $($installerEvidence.Path)"
        "- Size: $($installerEvidence.Length)"
        "- SHA256: $($installerEvidence.Sha256)"
        "- Signature: $($installerEvidence.SignatureStatus)"
    ) -join [Environment]::NewLine
} elseif ($null -ne $installerEvidence) {
    "- Error: $($installerEvidence.Error)"
} else {
    "- Not provided"
}

$summary = @(
    "# Nimbus Windows Installer Fixture Evidence"
    ""
    "- Captured: $($evidence.CapturedAt)"
    "- Stage: $Stage"
    "- Output: $resolvedOutputDir"
    "- Notes: $Notes"
    ""
    "## Installer"
    ""
    $installerSummary
    ""
    "## Web UI Probe"
    ""
    "- URL: $($evidence.WebUi.Url)"
    "- Status: $($evidence.WebUi.Status)"
    "- Skipped: $($evidence.WebUi.Skipped)"
    "- Error: $($evidence.WebUi.Error)"
    ""
    "## Services"
    ""
    $serviceSummary
    ""
    "## Uninstall Entries"
    ""
    $uninstallSummary
    ""
    "Full machine-readable evidence: ``fixture-evidence.json``"
) -join [Environment]::NewLine

$summary | Set-Content -LiteralPath $summaryPath -Encoding UTF8

Write-Host "Nimbus fixture evidence written to:"
Write-Host "  $summaryPath"
Write-Host "  $jsonPath"
