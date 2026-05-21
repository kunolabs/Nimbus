# Nimbus v0.1.0-alpha.1 - Draft

Status: draft. Do not move this file to `release_notes/` or tag
`nimbus-v0.1.0-alpha.1` until the Windows installer fixture passes.

## What This Alpha Is

This is the first compatibility-first Nimbus alpha. Nimbus is the Kuno Labs
host fork in the Vibepollo, Apollo, and Sunshine lineage. The goal of this alpha
is to prove that Nimbus can publish a clearly branded Windows host package
without breaking inherited install and runtime compatibility before the project
has wider testers.

## Nimbus-Specific Changes

- Established Nimbus public-maintenance docs, release process, upstream sync
  policy, and issue-radar workflow.
- Hardened release automation so public releases require `nimbus-v*` tags.
- Disabled inherited signing, symbol publishing, WebRTC publishing, and
  automatic issue-closure paths until Nimbus-owned policy and secrets exist.
- Rebranded public Windows package output to Nimbus, including
  `NimbusSetup.exe`, `Nimbus.msi`, Kuno Labs publisher metadata, and Nimbus
  support links.
- Fixed Windows package target dependencies so `package_installer` builds the
  helper executables and Web UI payload before CPack/WiX packaging.
- Documented the first alpha tag policy and installer fixture gate.
- Retargeted the Web UI release checks to `kunolabs/Nimbus` and filtered update
  banners to Nimbus-owned `nimbus-v*` tags so the alpha cannot advertise an
  inherited Vibepollo download or downgrade path.
- Rebranded the visible Vue Web UI shell, English UI copy, static first-run
  onboarding, login header, favicon, and Windows status messages to Nimbus.
- Added the first Nimbus host-console token pass so the Web UI moves away from
  inherited Apollo/Sunshine visual identity while keeping compatibility-safe
  runtime identifiers in place.
- Retargeted user-visible tray, launcher export, service display, fallback host
  naming, and in-app client-control help surfaces to Nimbus-owned wording and
  docs.
- Made the uninstaller quick-tip panel uninstall-specific instead of showing
  install/upgrade guidance.

## Compatibility Notes

Nimbus v0.1.0-alpha.1 intentionally keeps several inherited runtime identifiers
in place for compatibility while the fork gathers real install and upgrade
feedback:

- Some service names, app ids, config filenames, and migration checks may still
  mention Apollo, Vibepollo, Sunshine, or Vibeshine.
- Windows install and upgrade behavior follows inherited package lineage until
  a dedicated migration plan is built and tested.
- Existing Apollo or Vibepollo users should treat this alpha as a test build and
  back up configuration before installing over a daily-use host.

## Verification

Historical local package validation passed for the Phase C packaging slice:

- `NimbusSetup.exe` was generated locally.
- `Nimbus.msi` was generated locally.
- Authenticode status was `NotSigned`, as expected for the unsigned alpha path.
- SignPath signing and symbol publishing were skipped.

Current source validation has passed after the UI and status-message rebrand:

- Web UI production build passes with inherited large vendor chunk warnings.
- English locale JSON files parse successfully.
- Native Windows host target builds successfully when MSYS2 UCRT64 is on
  `PATH`.
- The current full package target passes when `WIX` points at WiX Toolset v3.14.1
  portable binaries and the WiX ICE validation step runs outside the Codex
  sandbox.

Current local package artifacts from commit `0af1f3b8`:

| Artifact | Size | SHA256 |
| --- | ---: | --- |
| `NimbusSetup.exe` | 25,871,872 | `4091BACCA4CF23356C583956606D18451D3516ABDA8D35438996A9693BE66F20` |
| `Nimbus.msi` | 25,606,719 | `6B348D3516352DE46690940A0241B9DB38B1FA4F56ECF856A4BE7E52BE7A63EC` |

These are local validation artifacts, not release candidates, until the VM
fixture checks below are completed and recorded.

Partial manual VM observations from the current candidate loop:

- Fresh install defaults to `C:\Program Files\Nimbus`.
- Visible installer, tray-opened Web UI, first-run, dashboard, and uninstall
  confirmation surfaces use Nimbus wording.
- The installed service runs with Nimbus user-visible description text while
  preserving the inherited internal `ApolloService` service name for this alpha.
- No Microsoft Defender warning was observed during the manual install smoke.
- The uninstaller quick-tip panel was fixed after VM feedback and still needs a
  retest with the `0.0.0.41` candidate.

Pending before release:

- Retest the `0.0.0.41` uninstaller quick-tip copy.
- Uninstall and reinstall behavior.
- Compatible-client pairing smoke.
- Short local-network stream smoke.
- Upgrade behavior from Apollo and/or Vibepollo where practical.

## Known Issues And Caveats

- The first alpha is expected to be unsigned unless Nimbus-owned signing is
  configured before release.
- Windows SmartScreen or antivirus products may warn on unsigned installer
  artifacts.
- Runtime identity migration is not complete; this alpha is branded Nimbus at
  the public package layer, not a full rename of every inherited runtime id.
- Some compatibility routes, filenames, service names, icons, docs links, and
  internal comments may still include inherited Vibepollo, Apollo, or Sunshine
  wording until each migration surface has a dedicated test plan.
- Symbols, SignPath signing, WebRTC asset publishing, and automatic issue
  closure remain disabled.

## Upgrade Guidance

Use a VM, snapshot, or non-critical host first. If testing an upgrade from
Apollo or Vibepollo, back up the existing configuration and record whether
credentials, paired-client state, services, shortcuts, and uninstall entries
survive the upgrade.
