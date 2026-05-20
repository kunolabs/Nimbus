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
  automatic fixed-issue closure until Nimbus-owned policy and secrets exist.
- Rebranded public Windows package output to Nimbus, including
  `NimbusSetup.exe`, `Nimbus.msi`, Kuno Labs publisher metadata, and Nimbus
  support links.
- Fixed Windows package target dependencies so `package_installer` builds the
  helper executables and Web UI payload before CPack/WiX packaging.
- Documented the first alpha tag policy and installer fixture gate.

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

Local package validation has passed for the Phase C packaging slice:

- `NimbusSetup.exe` was generated locally.
- `Nimbus.msi` was generated locally.
- Authenticode status was `NotSigned`, as expected for the unsigned alpha path.
- SignPath signing and symbol publishing were skipped.

Pending before release:

- Fresh install in a Windows VM or snapshot fixture.
- Web UI launch after install.
- Compatible-client pairing smoke.
- Short local-network stream smoke.
- Uninstall and reinstall behavior.
- Upgrade behavior from Apollo and/or Vibepollo where practical.

## Known Issues And Caveats

- The first alpha is expected to be unsigned unless Nimbus-owned signing is
  configured before release.
- Windows SmartScreen or antivirus products may warn on unsigned installer
  artifacts.
- Runtime identity migration is not complete; this alpha is branded Nimbus at
  the public package layer, not a full rename of every inherited runtime id.
- Symbols, SignPath signing, WebRTC asset publishing, and automatic issue
  closure remain disabled.

## Upgrade Guidance

Use a VM, snapshot, or non-critical host first. If testing an upgrade from
Apollo or Vibepollo, back up the existing configuration and record whether
credentials, paired-client state, services, shortcuts, and uninstall entries
survive the upgrade.
