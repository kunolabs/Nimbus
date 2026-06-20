# Nimbus Fixture Matrix

Snapshot date: 2026-05-23

This matrix records real tested host/client setups. Keep it factual: only add a
row after a local or community tester has actually run the setup.

## Status Legend

| Status | Meaning |
| --- | --- |
| Pass | Tested successfully with no observed issue in the recorded scenario. |
| Partial | Stream works, but there is a caveat or unverified surface. |
| Fail | Reproduced failure with enough evidence to investigate. |
| Planned | Intended fixture, not yet tested. |

## Current Fixtures

| Date | Status | Host | Client | Display | Network | Scenario | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2026-05-21 | Partial | Windows 11 VM on VMware, AMD Ryzen 7 5700X3D host, VMware SVGA 3D | Artemis on Shield TV | 1920x1080@60, WebRTC observed in UI | LAN, VM IP 192.168.51.128 | Pair, stream, disconnect | Manual VM smoke passed; service name remains inherited `ApolloService`; next build must retest naming and upstream display fixes. |

## Planned Fixtures

| Priority | Fixture | Why |
| --- | --- | --- |
| High | Windows 11 physical host to Shield TV Pro 4K60 SDR | Main living-room baseline. |
| High | Windows 11 physical host to Shield TV Pro 4K60 HDR | Validates HDR/10-bit sync and client behavior. |
| High | SudoVDA virtual display restore after disconnect | Core inherited reliability issue and upstream sync validation. |
| Medium | Steam Deck/handheld native resolution profile | Client Profiles direction. |
| Medium | Tailscale remote stream | Network diagnostics direction. |
| Medium | Playnite Fullscreen launch and clean exit | Library integration and app lifecycle confidence. |

## Evidence Checklist

- Nimbus commit hash.
- Installer artifact hash if testing a packaged build.
- Host OS build, GPU, driver, and display type.
- Client device, client app/version, resolution, FPS, codec, HDR.
- Network path: LAN, Wi-Fi, Ethernet, Tailscale, WireGuard, WAN.
- Pairing result.
- Launch result.
- Disconnect/restore result.
- Exported log bundle path or attached issue link.

