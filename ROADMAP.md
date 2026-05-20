# Nimbus Roadmap

This roadmap is intentionally practical. Nimbus is a fresh public-maintenance
fork, so the first milestone is trust and reproducibility before feature work.

## Phase 0: Public Maintainer Baseline

Status: in progress

- Establish professional project documentation.
- Make upstream lineage and fork status explicit.
- Add contribution, support, security, conduct, and governance docs.
- Clean issue templates that still refer to the wrong project identity.
- Adopt the Nimbus branch and release protocol.
- Keep all changes documentation-only.

## Phase 1: Local Build and Release Reality Check

Goal: prove that the fork can be built, packaged, and tested locally.

- Keep documented remotes for `upstream-vibepollo`, `upstream-apollo`, and
  `upstream-sunshine`.
- Run a clean source build on Windows.
- Record exact build prerequisites and commands.
- Identify which inherited CI workflows are safe to keep, pause, or rewrite.
- Confirm whether release artifacts can be produced without private maintainer
  assumptions.

## Phase 2: Safe Nimbus Host Rebrand

Goal: rename public surfaces without breaking users.

- Inventory all Apollo, Sunshine, and Vibepollo names in user-facing surfaces.
- Separate harmless documentation strings from risky runtime identifiers.
- Rename README, issue templates, docs, release notes, and GitHub metadata first.
- Plan binary, service, config, certificate, and installer naming separately.
- Preserve migration notes for existing Vibepollo/Apollo users.

## Phase 3: Streaming Reliability Focus

Goal: build maintainer credibility through user-visible stability work.

- Prioritize Windows 11, NVIDIA Shield TV Pro, Android TV, and Moonlight/Artemis
  compatibility reports.
- Improve logs and diagnostics before changing capture behavior.
- Create reproducible issue templates for frame pacing, WGC, virtual display,
  HDR, audio, controller, and Playnite issues.
- Keep performance claims tied to real test setups.

## Phase 4: Lucent Client Track

Goal: start the client fork deliberately.

- Fork the Artemis/Moonlight Android lineage into Lucent.
- Establish package-name, signing, and Android TV strategy.
- Validate Nimbus host compatibility with Artemis, Moonlight Android, and Lucent.
- Keep client changes separate from host changes unless a protocol feature needs
  coordinated releases.

## Immediate Next Move

The next engineering pass should harden CI/release behavior before any branded
Nimbus release:

1. Use `docs/release-build-audit.md` as the release automation baseline.
2. Use `docs/upstream-issue-radar.md` to choose the first reliability issue.
3. Adapt release workflows to require `nimbus-v*` tags.
4. Disable or retarget signing, symbols, and WebRTC publishing defaults.
5. Set up a known-good Windows build environment and record the exact command.
