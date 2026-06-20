param(
    [ValidateSet('prepare', 'verify')]
    [string]$Stage = 'prepare',
    [string]$InstallRoot = '',
    [string]$Marker = 'nimbus-upgrade-preservation-fixture'
)

$ErrorActionPreference = 'Stop'

function Resolve-InstallRoot {
    param([string]$ExplicitInstallRoot)

    if (-not [string]::IsNullOrWhiteSpace($ExplicitInstallRoot)) {
        return [System.IO.Path]::GetFullPath($ExplicitInstallRoot)
    }

    $registryRoots = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $candidate = Get-ItemProperty -Path $registryRoots -ErrorAction SilentlyContinue |
        Where-Object {
            $_.DisplayName -match 'Nimbus|Vibepollo' -and
            -not [string]::IsNullOrWhiteSpace($_.InstallLocation)
        } |
        Sort-Object DisplayName |
        Select-Object -First 1

    if ($candidate) {
        return [System.IO.Path]::GetFullPath([string]$candidate.InstallLocation)
    }

    throw 'InstallRoot was not provided and no Nimbus/Vibepollo InstallLocation was found in the registry.'
}

function Get-SentinelFiles {
    param([string]$Root)

    return @(
        @{
            Path = Join-Path $Root 'custom-root-note.txt'
            Content = "$Marker root sentinel"
        },
        @{
            Path = Join-Path $Root 'config\custom-settings.json'
            Content = "{`"marker`":`"$Marker`",`"kind`":`"config`"}"
        },
        @{
            Path = Join-Path $Root 'scripts\custom-hook.ps1'
            Content = "Write-Output '$Marker script sentinel'"
        },
        @{
            Path = Join-Path $Root 'credentials\custom-cert.pem'
            Content = "-----BEGIN NIMBUS FIXTURE-----`n$Marker`n-----END NIMBUS FIXTURE-----"
        },
        @{
            Path = Join-Path $Root 'logs\custom-operator.log'
            Content = "$Marker log sentinel"
        },
        @{
            Path = Join-Path $Root 'session_history\custom-session.json'
            Content = "{`"marker`":`"$Marker`",`"kind`":`"session`"}"
        }
    )
}

$resolvedRoot = Resolve-InstallRoot -ExplicitInstallRoot $InstallRoot
$sentinels = Get-SentinelFiles -Root $resolvedRoot

if ($Stage -eq 'prepare') {
    foreach ($sentinel in $sentinels) {
        $directory = Split-Path -Parent $sentinel.Path
        if (-not [string]::IsNullOrWhiteSpace($directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        Set-Content -LiteralPath $sentinel.Path -Value $sentinel.Content -Encoding UTF8
        Write-Output "Wrote sentinel: $($sentinel.Path)"
    }

    Write-Output "Prepared upgrade preservation fixture under: $resolvedRoot"
    Write-Output 'Now run the Nimbus upgrade, then rerun this script with -Stage verify.'
    exit 0
}

$missing = New-Object System.Collections.Generic.List[string]
$changed = New-Object System.Collections.Generic.List[string]
foreach ($sentinel in $sentinels) {
    if (-not (Test-Path -LiteralPath $sentinel.Path -PathType Leaf)) {
        $missing.Add($sentinel.Path)
        continue
    }

    $actual = Get-Content -LiteralPath $sentinel.Path -Raw
    if ($actual.TrimEnd() -ne $sentinel.Content.TrimEnd()) {
        $changed.Add($sentinel.Path)
    }
}

if ($missing.Count -gt 0 -or $changed.Count -gt 0) {
    if ($missing.Count -gt 0) {
        Write-Error "Missing sentinel file(s): $($missing -join '; ')"
    }
    if ($changed.Count -gt 0) {
        Write-Error "Changed sentinel file(s): $($changed -join '; ')"
    }
    exit 1
}

Write-Output "All upgrade preservation sentinels survived under: $resolvedRoot"
