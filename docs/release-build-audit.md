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
| `.github/workflows/ci.yml` | push, pull request, manual | High | Builds Windows and can create GitHub releases from version tags. Still uses upstream-style tag parsing, Vibepollo product names, issue closing, and release artifact names. |
| `.github/workflows/ci-windows.yml` | reusable workflow | High | Builds Windows artifacts, downloads pinned WebRTC artifacts, optionally signs artifacts, and optionally publishes symbols. |
| `.github/workflows/webrtc-release.yml` | manual | High | Can publish pinned WebRTC release assets with `contents: write`. Uses Vibepollo dependency paths and inherited WebRTC release scripts. |
| `.github/workflows/fixed-issue-follow-up.yml` | issue label, release published | Medium | Comments on and closes issues labeled `fixed`. Useful later, but should be reworded and checked before relying on it publicly. |
| `.github/workflows/logs-needed-reminder.yml` | issue/comment events | Medium | Uses inherited Vibepollo/Sunshine log filename detection and instructions. Needs Nimbus wording and filename strategy. |
| `.github/workflows/logs-needed-closure.yml` | scheduled or issue state flow | Medium | Can close issues for missing logs. Needs maintainer policy review before use. |
| `.github/workflows/environment-specific-closure.yml` | issue label | Medium | Closes issues as not planned when labeled `environment-specific`. The wording still says Vibepollo. |

## Release Automation Findings

The inherited release automation is not ready to use as-is for Nimbus releases.

Key blockers:

- Release candidate detection accepts upstream-style tags like `1.15.4` and
  `v1.15.4`, not the approved Nimbus `nimbus-v*` tag protocol.
- Release notes are expected under `release_notes/<version>.md`, where the
  version is parsed from the upstream-style tag.
- Product and artifact naming still uses `Vibepollo`.
- Symbol publishing defaults to `Nonary/vibeshine_symbols`.
- SignPath defaults still use the upstream Vibepollo project slug and
  organization id.
- WebRTC artifacts point at `Nonary/vibeshine` in
  `third-party/webrtc-artifacts/windows-x64.json`.
- Release automation can close issues labeled `fixed`; this should not be
  enabled until Nimbus release notes and issue policy are ready.

Decision: keep CI available for investigation, but do not intentionally trigger
release publishing until release automation is adapted to Nimbus naming and tag
rules.

## Build And Packaging Findings

The source still has inherited runtime and packaging identity:

- `CMakeLists.txt` declares `project(Vibepollo ...)`.
- `PROJECT_FQDN` is still `dev.lizardbyte.app.Sunshine`.
- `WINDOWS_APP_USER_MODEL_ID` is still `Nonary.Vibepollo`.
- CPack package name is still `Vibepollo`.
- Windows install directory is still `Apollo`.
- Windows WiX product family is seeded with `Vibepollo`.
- Bootstrapper text, support links, and output names still use Vibepollo.
- Several installer paths intentionally detect or migrate Apollo and Sunshine.

These should not be renamed in one broad sweep. Runtime identifiers, installer
upgrade codes, service names, config paths, and app ids can affect upgrades and
coexistence with Apollo/Vibepollo/Sunshine.

## Local Validation Attempt

Commands attempted:

```bash
cmake --version
git submodule status --recursive
```

Result:

- `cmake` is not available on this PATH.
- `git submodule status --recursive` failed in this PowerShell/Git setup because
  Git's submodule helper shell could not find `basename`, `sed`, and
  `git-sh-setup`.

These are local environment blockers. They do not prove the project build is
broken. The next local build pass should use MSYS2 UCRT64 or a configured build
environment matching `docs/building.md`.

## Required Secrets Before Release CI

| Secret | Purpose | Current Risk |
| --- | --- | --- |
| `SIGNPATH_API_TOKEN` | Submit/sign Windows artifacts | Upstream SignPath project defaults still reference Vibepollo. |
| `SYMBOL_TOKEN` | Publish private symbols release | Defaults to `Nonary/vibeshine_symbols`; unsafe for Nimbus. |
| `GITHUB_TOKEN` | Release creation and issue automation | Built-in token is fine, but workflows need Nimbus tag and wording changes first. |

## Recommended Next Actions

1. Keep release workflows enabled only for read-only/manual investigation.
2. Add a CI hardening pass before the first Nimbus release:
   - require `nimbus-v*` tags for release publication;
   - rename release product metadata deliberately;
   - disable symbol publishing until a Nimbus symbol repo exists;
   - disable SignPath submission until a Nimbus signing project exists;
   - reword issue automation from Vibepollo to Nimbus.
3. Create a dedicated packaging identity plan before changing installer/runtime
   identifiers.
4. Set up a known-good Windows build environment and record exact commands.
5. Use `docs/upstream-issue-radar.md` to select the first credibility fixes.

## Current Verdict

Nimbus is ready for documentation and issue triage work. It is not yet ready for
branded release publication.
