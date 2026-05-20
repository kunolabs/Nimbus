# Nimbus Release And Build Audit

Snapshot date: 2026-05-20

This audit captures the first maintainer pass after transferring Nimbus to the
`kunolabs` organization. It is intentionally conservative: the current goal is
to understand inherited automation before changing release behavior.

## Current Repository State

- Public repository: `https://github.com/kunolabs/Nimbus`
- Active branch: `master`
- Immediate upstream: `https://github.com/Nonary/Vibepollo`
- Reference upstreams:
  - `https://github.com/ClassicOldSong/Apollo`
  - `https://github.com/LizardByte/Sunshine`
- Local upstream remotes are fetch-only; push URLs are disabled for upstream
  remotes.
- Upstream branch heads were fetched with `--no-tags`.
- No upstream tags were imported locally during this pass.

## Workflow Inventory

| Workflow | Trigger | Risk | Notes |
| --- | --- | --- | --- |
| `.github/workflows/ci.yml` | push, pull request, manual | High | Builds Windows and can create GitHub releases from `nimbus-v*` tags. Release creation remains blocked on package-output validation. |
| `.github/workflows/ci-windows.yml` | reusable workflow | High | Builds Windows artifacts, downloads pinned WebRTC artifacts, optionally signs artifacts, and optionally publishes symbols. |
| `.github/workflows/webrtc-release.yml` | manual | High | Can publish pinned WebRTC release assets with `contents: write`. Publishing defaults to off and requires an explicit Nimbus confirmation string. |
| `.github/workflows/fixed-issue-follow-up.yml` | issue label, release published | Medium | Comments on and closes issues labeled `fixed`. Useful later, but should be reworded and checked before relying on it publicly. |
| `.github/workflows/logs-needed-reminder.yml` | issue/comment events | Medium | Uses inherited Vibeshine/Sunshine log filename detection for compatibility. Instructions now use Nimbus wording. |
| `.github/workflows/logs-needed-closure.yml` | scheduled or issue state flow | Medium | Can close issues for missing logs. Needs maintainer policy review before use. |
| `.github/workflows/environment-specific-closure.yml` | issue label | Medium | Closes issues as not planned when labeled `environment-specific`. Wording now says Nimbus. |

## Release Automation Findings

The inherited release automation was not ready to use as-is for Nimbus releases.
A hardening pass has now been applied so accidental upstream-style releases are
less likely.

Original blockers:

- Release candidate detection accepted upstream-style tags like `1.15.4` and
  `v1.15.4`, not the approved Nimbus `nimbus-v*` tag protocol.
- Release notes are expected under `release_notes/<version>.md`, where the
  version is parsed from the upstream-style tag.
- Product and artifact naming still uses `Vibepollo`.
- Symbol publishing defaulted to `Nonary/vibeshine_symbols`.
- SignPath defaults still use the upstream Vibepollo project slug and
  organization id.
- WebRTC artifacts point at `Nonary/vibeshine` in
  `third-party/webrtc-artifacts/windows-x64.json`.
- Release automation can close issues labeled `fixed`; this should not be
  enabled until Nimbus release notes and issue policy are ready.

Applied hardening:

- Release candidate detection now requires `nimbus-v*` tags.
- Release metadata now rejects non-Nimbus release tags.
- Symbol publishing is disabled by default from the main CI caller.
- Tag-triggered symbol publishing in the Windows reusable workflow is disabled;
  symbols require explicit `publish_symbols`.
- The default symbol repository is retargeted to `kunolabs/nimbus-symbols`, but
  publishing remains disabled until that repository and token policy exist.
- SignPath submission is disabled by passing no signing token to the Windows
  reusable workflow and blanking SignPath environment values.
- WebRTC publishing defaults to `false` and requires an explicit confirmation
  string.
- Main release creation no longer closes `fixed` issues directly.
- The separate fixed-issue release closer is disabled.

Remaining release blocker: package branding has been updated to emit
Nimbus-named artifacts, but a local Windows package build has not yet verified
the final installer output. The release job looks for `NimbusSetup*`.

Decision: CI is safer for normal branch work and manual investigation, but do
not intentionally create a Nimbus release tag until package output is validated
locally.

## Build And Packaging Findings

The source now has Nimbus package branding but still has inherited runtime
identity:

- `CMakeLists.txt` declares `project(Nimbus ...)`.
- `PROJECT_FQDN` is still `dev.lizardbyte.app.Sunshine`.
- `WINDOWS_APP_USER_MODEL_ID` is still `Nonary.Vibepollo`.
- CPack package name is now `Nimbus`.
- Windows install directory is still `Apollo`.
- Windows WiX product family is seeded with `Vibepollo`.
- Bootstrapper text, support links, and output names now use Nimbus.
- Several installer paths intentionally detect or migrate Apollo and Sunshine.

Runtime identifiers should not be renamed in one broad sweep. Upgrade codes,
service names, config paths, and app ids can affect upgrades and coexistence
with Apollo/Vibepollo/Sunshine.

## Local Validation Attempt

Commands attempted:

```bash
cmake --version
git submodule status --recursive
git diff --check
python -c "import yaml ..."
powershell XML and PowerShell parser checks
powershell -File packaging/windows/bootstrapper/build_bootstrapper.ps1 -BuildDir .\build\phasec-bootstrapper -UninstallOnly -DisableSignPath
```

Result:

- `cmake` is not available on this PATH.
- `git submodule status --recursive` failed in this PowerShell/Git setup because
  Git's submodule helper shell could not find `basename`, `sed`, and
  `git-sh-setup`.
- Diff whitespace validation passed.
- GitHub workflow YAML parsing passed.
- Changed WiX/app manifest XML parsing passed.
- Changed PowerShell script parsing passed.
- The bootstrapper source compiled successfully in uninstall-only mode with the
  local .NET Framework C# compiler.
- A full CMake/WiX package build was not run in this environment, so
  `NimbusSetup.exe` still needs package-level validation.

These are local environment blockers. They do not prove the project build is
broken. The next local build pass should use MSYS2 UCRT64 or a configured build
environment matching `docs/building.md`.

## Required Secrets Before Release CI

| Secret | Purpose | Current Risk |
| --- | --- | --- |
| `SIGNPATH_API_TOKEN` | Submit/sign Windows artifacts | SignPath has no inherited upstream org/policy fallback now, but CI still disables signing until Nimbus-owned settings exist. |
| `SYMBOL_TOKEN` | Publish private symbols release | Retargeted to `kunolabs/nimbus-symbols`, but still disabled until a Nimbus symbol repo and policy exist. |
| `GITHUB_TOKEN` | Release creation and issue automation | Built-in token is fine, but workflows need Nimbus tag and wording changes first. |

## Recommended Next Actions

1. Validate the Phase C package-branding slice with a known-good Windows build.
2. Set up a known-good Windows build environment and record exact commands.
3. Review issue automation policy before enabling automatic issue closures.
4. Create a Nimbus symbol publishing plan before enabling `publish_symbols`.
5. Use `docs/upstream-issue-radar.md` to select the first credibility fixes.

## Current Verdict

Nimbus is ready for documentation and issue triage work. It is not yet ready for
branded release publication.
