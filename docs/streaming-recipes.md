# Nimbus Streaming Recipes

Snapshot date: 2026-05-23

These recipes are starting points for repeatable community testing. They are not
guaranteed optimal settings. Record what actually works in
`docs/fixture-matrix.md` after testing.

## Shield TV / Android TV 4K60

Best for living-room controller-first play.

| Setting | Starting Point |
| --- | --- |
| Client | Artemis or Moonlight Android TV |
| Resolution | 3840x2160 |
| Frame rate | 60 FPS |
| Codec | HEVC when supported |
| HDR | Enable only after SDR is stable |
| Network | Wired Ethernet preferred |
| Host display | SudoVDA virtual display or physical 4K display |
| App launch | Playnite Fullscreen or direct game app |

Checks:

- Pair client and confirm stream starts from the TV device.
- Confirm the Windows cursor is not visible in controller-first games.
- Confirm disconnect restores the expected host display state.
- Export logs after one successful stream and one disconnect.

## Shield TV / Android TV 4K120

Best for high-refresh displays where the full chain supports 120 Hz.

| Setting | Starting Point |
| --- | --- |
| Client | Artemis or Moonlight Android TV |
| Resolution | 3840x2160 |
| Frame rate | 120 FPS |
| Codec | HEVC or AV1 if both sides support it |
| HDR | Enable after 4K120 SDR is stable |
| Network | Wired Ethernet or proven low-latency Wi-Fi 6/6E |
| Frame pacing | Validate display refresh, RTSS cap, and client-reported FPS |

Checks:

- Confirm the host display is actually running near 120 Hz.
- Watch for 119.88/120 mismatch and frame pacing jitter.
- Record whether WGC, DXGI, or frame-generation capture is used.

## Steam Deck / Handheld

Best for handheld streaming with client-native aspect ratio.

| Setting | Starting Point |
| --- | --- |
| Resolution | 1280x800 or client-native |
| Frame rate | 60, 90, or native FPS depending on client |
| Bitrate | Start conservative, then increase |
| Input | Gamepad-first; test Steam Input behavior |
| Launcher | Playnite, Steam Big Picture, or direct app |

Checks:

- Confirm the game renders without aspect-ratio stretching.
- Confirm controller order and rumble behavior.
- Confirm bitrate does not outrun Wi-Fi conditions.

## OLED 4K HDR

Best for enthusiasts validating HDR and 10-bit behavior.

| Setting | Starting Point |
| --- | --- |
| Resolution | 3840x2160 |
| Frame rate | 60 or 120 FPS |
| Codec | HEVC Main10 or AV1 10-bit where supported |
| HDR | Validate SDR first, then HDR |
| Display | Physical HDR display or virtual display with known-good HDR metadata |

Checks:

- Confirm Windows HDR state before and during stream.
- Confirm client HDR mode actually engages.
- Record encoder, bit depth, and client codec.
- Export logs if HDR falls back to SDR or the image looks washed out.

## Headless Windows Host

Best for PCs without an attached gaming display.

| Setting | Starting Point |
| --- | --- |
| Display | SudoVDA first; dummy plug as fallback |
| Restore | Create a golden display snapshot before testing |
| App launch | Direct app first, then Playnite |
| Access | Keep local/remote recovery path available |

Checks:

- Confirm the virtual display appears before pairing.
- Confirm stream-end restore does not strand the host in the wrong layout.
- Export display-helper logs after restore.

## Remote Tailscale / WireGuard

Best for controlled remote-home testing.

| Setting | Starting Point |
| --- | --- |
| Pairing | Pair locally first if possible |
| Address | Use the overlay IP only after LAN success |
| Bitrate | Start lower than LAN |
| Network | Verify direct path vs relay where your overlay exposes it |

Checks:

- Confirm LAN stream works before remote testing.
- Record whether manual IP add was needed.
- Export logs for RTSP, connection timeout, or disconnect failures.

## Cursor Troubleshooting Mini-Recipe

Use this when the Windows cursor remains visible, disappears, duplicates, or
appears offset.

1. Identify which cursor is visible: host cursor, client cursor, or game cursor.
2. Check whether the client has a local cursor toggle or touch/mouse mode.
3. Test one controller-first game and one mouse-first desktop/app session.
4. Note whether the host is using a physical display, SudoVDA, dummy plug, or
   HDR/virtual-display setup.
5. Search Nimbus logs for `cursor`, `mouse`, `input`, and capture method.
