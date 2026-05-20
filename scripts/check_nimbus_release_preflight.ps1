#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$TagName = "nimbus-v0.1.0-alpha.1",
    [string]$FixturePath = "docs/windows-installer-fixture.md",
    [string]$ReleaseNotesDir = "release_notes",
    [switch]$SkipGitChecks,
    [switch]$AllowExistingTag,
    [switch]$AllowDirtyWorkingTree
)

$ErrorActionPreference = "Stop"

$script:Errors = New-Object System.Collections.Generic.List[string]
$script:Warnings = New-Object System.Collections.Generic.List[string]
$script:Passes = New-Object System.Collections.Generic.List[string]

function Add-Pass([string]$Message) {
    $script:Passes.Add($Message) | Out-Null
}

function Add-Warning([string]$Message) {
    $script:Warnings.Add($Message) | Out-Null
}

function Add-Blocker([string]$Message) {
    $script:Errors.Add($Message) | Out-Null
}

function Test-GitAvailable {
    return $null -ne (Get-Command git -ErrorAction SilentlyContinue)
}

function Invoke-Git {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    $output = & git @Args 2>&1
    return [PSCustomObject]@{
        ExitCode = $LASTEXITCODE
        Output = ($output -join [Environment]::NewLine)
    }
}

function Get-ReleaseVersion([string]$Tag) {
    if ($Tag -match "^nimbus-v(.+)$") {
        return $Matches[1]
    }

    return ""
}

function Test-NimbusTag([string]$Tag) {
    return $Tag -match "^nimbus-v[0-9]+\.[0-9]+\.[0-9]+([-.][0-9A-Za-z.-]+)?$"
}

function Get-ReleaseNotesCandidates([string]$Tag, [string]$Dir) {
    $version = Get-ReleaseVersion -Tag $Tag
    $candidates = New-Object System.Collections.Generic.List[string]
    $candidates.Add((Join-Path $Dir "$Tag.md")) | Out-Null
    if (-not [string]::IsNullOrWhiteSpace($version)) {
        $candidates.Add((Join-Path $Dir "$version.md")) | Out-Null
    }
    return $candidates
}

function Test-ReleaseNotes([string]$Tag, [string]$Dir) {
    $candidates = Get-ReleaseNotesCandidates -Tag $Tag -Dir $Dir
    $existing = @($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
    $draftPath = Join-Path (Join-Path $Dir "drafts") "$Tag.md"

    if ($existing.Count -eq 0) {
        Add-Blocker "No top-level release notes found for $Tag. Expected one of: $($candidates -join ', ')."
        if (Test-Path -LiteralPath $draftPath -PathType Leaf) {
            Add-Warning "Draft release notes exist at $draftPath; promote them only after fixture evidence passes."
        }
        return
    }

    if ($existing.Count -gt 1) {
        Add-Warning "Multiple matching release note files exist: $($existing -join ', '). Prefer the exact tag file."
    }

    $notesPath = $existing[0]
    $notesText = Get-Content -Raw -LiteralPath $notesPath

    if ($notesText -match "(?im)^\s*Status:\s*draft\b") {
        Add-Blocker "$notesPath still contains draft status text."
    } else {
        Add-Pass "Release notes are promoted: $notesPath."
    }

    foreach ($requiredHeading in @(
            "Nimbus-Specific Changes",
            "Compatibility Notes",
            "Verification",
            "Known Issues"
        )) {
        if ($notesText -notmatch "(?im)^##\s+$([regex]::Escape($requiredHeading))\s*$") {
            Add-Warning "$notesPath does not contain a '$requiredHeading' section."
        }
    }
}

function Test-Fixture([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Add-Blocker "Installer fixture doc is missing: $Path."
        return
    }

    $fixtureText = Get-Content -Raw -LiteralPath $Path
    $requiredRows = @(
        "Fresh install on clean Windows 11 x64",
        "Launch Web UI after install",
        "Pair with a compatible client",
        "Start a short stream session",
        "Uninstall",
        "Reinstall after uninstall",
        "Windows SmartScreen/AV behavior"
    )

    foreach ($row in $requiredRows) {
        $escaped = [regex]::Escape($row)
        $matches = [regex]::Matches($fixtureText, "(?im)^\|\s*$escaped\s*\|\s*Yes\s*\|\s*([^|]+)\|")
        if ($matches.Count -eq 0) {
            Add-Blocker "Fixture row is missing or not marked required: $row."
            continue
        }

        $status = $matches[0].Groups[1].Value.Trim()
        if ($status -match "^(Pass|Passed)$") {
            Add-Pass "Fixture row passed: $row."
        } else {
            Add-Blocker "Fixture row '$row' is not passed yet; current status is '$status'."
        }
    }

    if ($fixtureText -notmatch "(?i)fixture-evidence\.json|fixture-summary\.md") {
        Add-Warning "Fixture doc does not reference captured fixture evidence outputs."
    }
}

function Test-GitState([string]$Tag) {
    if ($SkipGitChecks) {
        Add-Warning "Git checks skipped by request."
        return
    }

    if (-not (Test-GitAvailable)) {
        Add-Warning "git was not found on PATH; skipped git release checks."
        return
    }

    $insideWorkTree = Invoke-Git rev-parse --is-inside-work-tree
    if ($insideWorkTree.ExitCode -ne 0 -or $insideWorkTree.Output.Trim() -ne "true") {
        Add-Warning "Not inside a git worktree; skipped git release checks."
        return
    }

    $status = Invoke-Git status --porcelain
    if ($status.ExitCode -ne 0) {
        Add-Warning "Could not read git status: $($status.Output)"
    } elseif (-not $AllowDirtyWorkingTree -and -not [string]::IsNullOrWhiteSpace($status.Output)) {
        Add-Blocker "Working tree is dirty. Commit or stash changes before release preflight."
    } else {
        Add-Pass "Working tree state is acceptable."
    }

    $existingTag = Invoke-Git rev-parse --verify --quiet "refs/tags/$Tag"
    if ($existingTag.ExitCode -eq 0) {
        if ($AllowExistingTag) {
            Add-Warning "Tag already exists locally: $Tag."
        } else {
            Add-Blocker "Tag already exists locally: $Tag."
        }
    } else {
        Add-Pass "Tag does not already exist locally: $Tag."
    }
}

Write-Host "Nimbus release preflight"
Write-Host "Tag: $TagName"
Write-Host ""

if (Test-NimbusTag -Tag $TagName) {
    Add-Pass "Tag uses Nimbus release format."
} else {
    Add-Blocker "Unsupported release tag '$TagName'. Expected a tag like nimbus-v0.1.0-alpha.1."
}

if ($TagName -match "^(v?[0-9]+\.[0-9]+\.[0-9]+)") {
    Add-Blocker "Tag '$TagName' looks like an upstream-style release tag. Nimbus releases must use nimbus-v*."
}

Test-ReleaseNotes -Tag $TagName -Dir $ReleaseNotesDir
Test-Fixture -Path $FixturePath
Test-GitState -Tag $TagName

if ($script:Passes.Count -gt 0) {
    Write-Host "Passes:"
    foreach ($item in $script:Passes) {
        Write-Host "  [PASS] $item"
    }
    Write-Host ""
}

if ($script:Warnings.Count -gt 0) {
    Write-Host "Warnings:"
    foreach ($item in $script:Warnings) {
        Write-Host "  [WARN] $item"
    }
    Write-Host ""
}

if ($script:Errors.Count -gt 0) {
    Write-Host "Blockers:"
    foreach ($item in $script:Errors) {
        Write-Host "  [BLOCK] $item"
    }
    Write-Host ""
    Write-Host "Nimbus release preflight: BLOCKED"
    exit 1
}

Write-Host "Nimbus release preflight: PASS"
