# Nimbus

Nimbus is a community-maintained game streaming host fork based on
[Nonary/Vibepollo](https://github.com/Nonary/Vibepollo), which itself builds on
[ClassicOldSong/Apollo](https://github.com/ClassicOldSong/Apollo) and
[LizardByte/Sunshine](https://github.com/LizardByte/Sunshine).

The goal of Nimbus is to provide a polished, transparent, and contributor-friendly
host for Moonlight-compatible game streaming, with a practical focus on home
streaming, Android TV devices, virtual display reliability, frame pacing, and
clear public maintenance.

> [!NOTE]
> Nimbus is in its public-maintenance bootstrap stage. The repository still
> contains upstream Apollo, Sunshine, and Vibepollo names in code, assets,
> logs, packaging, and older documentation. Rebranding will be staged so
> functionality stays reviewable and users are not surprised by packaging
> changes.

## Project Scope

Nimbus is the host application. It is intended to run on the gaming PC or
streaming host machine.

Lucent is the planned companion client identity. Lucent will be handled as a
separate client project, expected to start from the Artemis/Moonlight Android
lineage.

## Upstream Lineage

| Project | Role | Relationship |
| --- | --- | --- |
| Nimbus | Host | This fork and public-maintenance effort |
| Vibepollo | Host | Immediate upstream base |
| Apollo | Host | Apollo-lineage host with Artemis-oriented features |
| Sunshine | Host | Original open source GameStream-compatible host lineage |
| Lucent | Client | Planned Nimbus companion client |
| Artemis / Moonlight Noir | Client | Expected Lucent upstream base |
| Moonlight Android | Client | Original Android client lineage |

Nimbus is not affiliated with, endorsed by, or an official replacement for any
upstream project. The intent is to maintain a respectful downstream fork, preserve
attribution, and upstream fixes where that is practical.

## Current Capabilities

Nimbus currently inherits the Vibepollo feature set, including:

- Windows Graphics Capture-oriented streaming improvements.
- Virtual display management through SudoVDA integration.
- Display automation and recovery safeguards for common Windows streaming setups.
- Playnite integration for library sync and launch workflows.
- RTSS and NVIDIA Control Panel integration for frame pacing workflows.
- Web UI improvements for host configuration and client management.
- WebRTC browser streaming support.
- Scoped API token support and session-based Web UI authentication.

These are inherited capabilities, not claims of original Nimbus authorship. New
Nimbus-specific changes will be documented in release notes as they are made.

## Status

This fork is not yet publishing Nimbus-branded releases. Until the first Nimbus
release exists, users who need stable binaries should continue using the upstream
project that already works for their setup.

Early Nimbus work is focused on:

- Establishing professional open source project documentation.
- Making build and release steps reproducible.
- Auditing inherited issue templates, support flow, and security handling.
- Planning a safe host rebrand from Vibepollo/Apollo naming to Nimbus.
- Preparing the future Lucent client track.

See [ROADMAP.md](ROADMAP.md) for the current maintainer roadmap.
See [docs/ui-identity-plan.md](docs/ui-identity-plan.md) for the staged Nimbus
Web UI identity direction.

## Building

Nimbus uses the inherited CMake-based host build. For now, follow the existing
source build documentation:

- [Building guide](docs/building.md)
- [Contributing guide](docs/contributing.md)

At a high level:

```bash
git clone https://github.com/kunolabs/Nimbus.git --recurse-submodules
cd Nimbus
cmake -B build -G Ninja -S .
ninja -C build
```

Platform-specific dependencies, optional WebRTC setup, packaging commands, and
test instructions are documented in the project docs.

## Contributing

Contributions are welcome once they are scoped, reviewable, and tested.

Good first contribution areas:

- Documentation cleanup.
- Reproducible build notes for Windows, Linux, and macOS.
- Issue reproduction details for real streaming setups.
- Small UI polish that improves clarity without changing behavior.
- Tests or diagnostics around existing host behavior.

Please read [docs/contributing.md](docs/contributing.md) before opening a pull
request.

## Security

Nimbus is remote-access-adjacent software: it handles pairing, network services,
host configuration, input, capture, and streaming. Treat security reports with
care.

Please read [SECURITY.md](SECURITY.md) before reporting a vulnerability. Do not
post exploit details, tokens, logs with secrets, or private host information in
public issues.

## Support

For general help, bug reports, and feature ideas, see [SUPPORT.md](SUPPORT.md).
Please include host OS, GPU, client device, client app, stream settings, and logs
when reporting runtime problems.

## Responsible AI Use

AI-assisted contributions are allowed, but contributors are responsible for the
result. Do not submit generated code or tests that you cannot explain, review,
and validate. Maintainers may ask for manual reproduction notes, test evidence,
or a smaller patch if a change is hard to audit.

## License

Nimbus is distributed under the GPL-3.0 license inherited from its upstream
lineage. See [LICENSE](LICENSE).

Additional notices are preserved in [NOTICE](NOTICE). Upstream projects and
contributors retain their original copyrights and attribution.
