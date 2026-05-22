# Upstream Issue Radar

Snapshot date: 2026-05-20

Source: open issues from `Nonary/Vibepollo`, fetched with GitHub CLI.

This file is not a copy of the upstream backlog. It is a triage radar for issues
that may matter to Nimbus users. Do not mirror upstream issues automatically.
Promote only issues that fit Nimbus goals and can be reproduced or clearly
scoped.

## Triage Buckets

- `Adopt now`: likely to affect Nimbus users directly and fits the first
  reliability milestone.
- `Watch`: useful signal, but needs reproduction, more reports, or upstream
  movement before Nimbus takes action.
- `Upstream fixed`: wait for the upstream fix or sync before taking separate
  action.
- `Docs/support`: mostly needs clearer docs, templates, diagnostics, or user
  guidance.
- `Needs hardware`: important, but requires specific GPU, display, client, or
  network setup to validate.

## Adopt Now

| Issue | Bucket | Why Nimbus Should Care |
| --- | --- | --- |
| [#238 Secondary monitor never recovers properly](https://github.com/Nonary/Vibepollo/issues/238) | Adopt now | Display recovery is core to the Nimbus host promise. Also suggests a useful dashboard warning when a saved display snapshot is stale. |
| [#235 Windows 10 install fails due to PATH variables](https://github.com/Nonary/Vibepollo/issues/235) | Adopt now | Installer reliability is a first-release blocker. This also intersects with Nimbus rebranding and install-path planning. |
| [#228 Virtual display does not reset on WebRTC stream close](https://github.com/Nonary/Vibepollo/issues/228) | Adopt now | Virtual display lifecycle cleanup is a high-value Nimbus reliability lane. |
| [#224 Crashes corrupting sunshine_state.json](https://github.com/Nonary/Vibepollo/issues/224) | Adopt now | State corruption after crashes is a trust issue. Nimbus should prefer backup, validation, and recovery behavior early. |
| [#223 Physical display setting unintended behavior](https://github.com/Nonary/Vibepollo/issues/223) | Adopt now | Physical monitor selection, virtual display overrides, and capture target behavior are central host features. The issue includes locally tested patch direction. |

## Watch

| Issue | Bucket | Why To Watch |
| --- | --- | --- |
| [#231 Low FPS issues while streaming](https://github.com/Nonary/Vibepollo/issues/231) | Watch | Important performance signal, but title alone lacks enough reproduction detail. Needs logs, capture mode, client, GPU, and stream settings. |
| [#222 RTSP Error 54 after update](https://github.com/Nonary/Vibepollo/issues/222) | Watch | Upgrade regression signal. Needs reproduction and logs before Nimbus owns it. |
| [#220 Session not closing after Playnite Fullscreen exit](https://github.com/Nonary/Vibepollo/issues/220) | Watch | Playnite lifecycle issues matter, but should be grouped with broader launcher/session cleanup. |
| [#219 App override resolution defaults to unintended resolution](https://github.com/Nonary/Vibepollo/issues/219) | Watch | App-specific overrides are relevant to Nimbus, especially for TV/client profiles. Needs reproduction. |
| [#213 Remote sessions fail over Tailscale/ZeroTier](https://github.com/Nonary/Vibepollo/issues/213) | Watch | Remote networking support matters, but Nimbus should first define support boundaries for VPN/overlay networks. |
| [#208 Web UI inaccessible after outside-LAN connection attempt](https://github.com/Nonary/Vibepollo/issues/208) | Watch | Potential network/session-state issue. Needs logs and security-minded review. |
| [#177 Frame limiter offset](https://github.com/Nonary/Vibepollo/issues/177) | Watch | Frame pacing matters, but needs a focused repro setup before action. |
| [#174 Framestutter/choppy low-FPS content](https://github.com/Nonary/Vibepollo/issues/174) | Watch | Strongly relevant to Shield/TV streaming quality, but likely needs hardware and capture-mode comparisons. |
| [#152 No system tray icon](https://github.com/Nonary/Vibepollo/issues/152) | Watch | User-facing reliability issue. Could become Adopt now if reproduced on current Nimbus base. |
| [#85 DRM Protected Content Error](https://github.com/Nonary/Vibepollo/issues/85) | Watch | Appears environment/client-flow sensitive. Needs careful reproduction before code changes. |

## Upstream Fixed

| Issue | Bucket | Why |
| --- | --- | --- |
| [#236 HEVC Main10/HDR not advertised despite `hevc_mode = 3`](https://github.com/Nonary/Vibepollo/issues/236) | Synced | Upstream 1.16.0-alpha.4 HDR/10-bit and NVENC API 12.1 fixes were cherry-picked into Nimbus after the 2026-05-23 upstream refresh. |
| [#238 Secondary monitor never recovers properly](https://github.com/Nonary/Vibepollo/issues/238) | Partially synced | Upstream 1.16.0-alpha.4 display-helper restore and golden snapshot fixes were cherry-picked. Keep VM validation before marking closed for Nimbus. |

## Docs And Support

| Issue | Bucket | Why |
| --- | --- | --- |
| [#237 Direct Steam Extension](https://github.com/Nonary/Vibepollo/issues/237) | Docs/support | Feature request. Keep as a future integration idea, not first maintenance work. |
| [#232 Custom cover art for Playnite apps and app reordering](https://github.com/Nonary/Vibepollo/issues/232) | Docs/support | Useful UX request but not a launch blocker. |
| [#226 Mac version planned?](https://github.com/Nonary/Vibepollo/issues/226) | Docs/support | Needs a clear platform-support statement. |
| [#206 Custom app cover not loading in Artemis](https://github.com/Nonary/Vibepollo/issues/206) | Docs/support | May belong to host metadata/client compatibility, but starts as support triage. |
| [#188 WebRTC input on touch devices](https://github.com/Nonary/Vibepollo/issues/188) | Docs/support | WebRTC UX request. Relevant later, not first host stability pass. |
| [#181 PIN always successful](https://github.com/Nonary/Vibepollo/issues/181) | Docs/support | Labeled `upstream bug`. Track, but avoid duplicating upstream unless Nimbus diverges. |
| [#29 Virus detected alerts](https://github.com/Nonary/Vibepollo/issues/29) | Docs/support | Installer trust and false-positive guidance should be addressed before Nimbus releases. |

## Needs Hardware Or Volunteers

| Issue | Bucket | Why |
| --- | --- | --- |
| [#216 Winuhid](https://github.com/Nonary/Vibepollo/issues/216) | Needs hardware | Input driver behavior needs a controlled Windows/client test setup. |
| [#172 AMD/AMF latency improvements](https://github.com/Nonary/Vibepollo/issues/172) | Needs hardware | Requires AMD GPU owners and repeatable latency measurements. |

## First Nimbus Backlog Candidates

1. Display snapshot staleness and recovery warning.
2. Installer PATH handling on Windows 10/11.
3. Virtual display cleanup when WebRTC sessions end.
4. Crash-safe state write and state backup/recovery.
5. Physical monitor app override behavior.

These are good early credibility fixes because they are user-visible, aligned
with Nimbus host reliability, and do not require inventing a new product vision.

## Follow-Up Rules

- Do not open a Nimbus issue from this file until the issue is reproduced,
  accepted as a known inherited upstream defect, or explicitly chosen as a
  tracking item.
- When creating a Nimbus issue from upstream signal, link back to the upstream
  issue and label it `upstream-radar`.
- If a fix is copied or adapted from an upstream issue comment, preserve
  attribution in the pull request.
- Keep hardware-dependent issues separate from generic host bugs.
