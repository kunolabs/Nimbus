# Upstream Issue Radar

Snapshot date: 2026-06-19

Source: open issues from `Nonary/Vibepollo`, fetched with GitHub CLI. Current
open count: 19.
Closed/status checks for tracked issues were verified with `gh issue view`.

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
| [#274 HDR washout on reconnect to a retained stream](https://github.com/Nonary/Vibepollo/issues/274) | Adopt now | Nimbus now suppresses HDR state changes during retained-resume virtual-display recreation to avoid the transient SDR flip. Validate on HDR WGC hardware before closing the risk. |
| [#271 Detached commands leave screensaver disabled after session teardown](https://github.com/Nonary/Vibepollo/issues/271) | Adopt now | Nimbus now snapshots and restores the Windows screen saver active flag across stream lifecycle. Validate with Playnite Fullscreen or another detached command before closing the risk. |

## Watch

| Issue | Bucket | Why To Watch |
| --- | --- | --- |
| [#278 RTX HDR creates blank/undeletable app entries](https://github.com/Nonary/Vibepollo/issues/278) | Watch | Fresh 1.17.0 beta 6 report suggests RTX HDR toggling can corrupt app entries, but it needs logs and reproduction before Nimbus owns it. |
| [#275 Slow Web UI in Firefox on v1.16.0-stable.3](https://github.com/Nonary/Vibepollo/issues/275) | Watch | Web UI responsiveness matters, but this is a single browser/GPU report with logs attached. Compare current Nimbus UI before taking code action. |
| [#272 Foundation-compatible runtime bitrate / ABR endpoints](https://github.com/Nonary/Vibepollo/issues/272) | Watch | Runtime bitrate control may matter for future clients, but it is product/API scope rather than first-pass host reliability. |
| [#269 Advanced WebRTC configuration and firewall traversal](https://github.com/Nonary/Vibepollo/issues/269) | Watch | Useful remote-streaming signal, but broad enough that Nimbus should first define support boundaries and avoid premature networking scope. |
| [#242 Device override dropdown missing](https://github.com/Nonary/Vibepollo/issues/242) | Watch | Config override UI parity is relevant, but should be grouped with the broader per-app and per-device override audit. |
| [#213 Remote sessions fail over Tailscale/ZeroTier](https://github.com/Nonary/Vibepollo/issues/213) | Watch | Remote networking support matters, but Nimbus should first define support boundaries for VPN/overlay networks. |
| [#208 Web UI inaccessible after outside-LAN connection attempt](https://github.com/Nonary/Vibepollo/issues/208) | Watch | Potential network/session-state issue. Needs logs and security-minded review. |
| [#177 Frame limiter offset](https://github.com/Nonary/Vibepollo/issues/177) | Watch | Frame pacing matters, and the VRR/RTSS offset use case is clearer now, but still needs client and hardware-specific reproduction before action. |

## Upstream Fixed

| Issue | Bucket | Why |
| --- | --- | --- |
| [#260 Video hangs in WGC](https://github.com/Nonary/Vibepollo/issues/260) | Upstream fixed | Closed upstream with `fixed` on 2026-06-10. Nimbus has the local constant-WGC cached-frame equivalent in the current WGC dirty work; keep a WGC freeze smoke case. |
| [#250 Per-app display settings cannot mirror primary without layout changes](https://github.com/Nonary/Vibepollo/issues/250) | Upstream fixed | Closed upstream on 2026-06-12. Keep display-override parity in Nimbus validation, not as a separate active item. |
| [#244 UAC prompt stream freeze/crash](https://github.com/Nonary/Vibepollo/issues/244) | Upstream fixed | Closed upstream on 2026-06-06. Retain as a UAC/display-transition regression case before dropping release-risk tracking. |
| [#241 Settings page crash in Lossless Scaling status API](https://github.com/Nonary/Vibepollo/issues/241) | Upstream fixed | Closed upstream with `fixed` on 2026-06-10. Nimbus now uses non-throwing default-path checks and returns a safe unavailable payload if the status handler fails. |
| [#228 Virtual display does not reset on WebRTC stream close](https://github.com/Nonary/Vibepollo/issues/228) | Upstream fixed | Closed upstream with `fixed` on 2026-06-12. Nimbus now forces final WebRTC display cleanup when no app remains and shortens the idle grace period while a virtual display is active. |
| [#224 Crashes corrupting sunshine_state.json](https://github.com/Nonary/Vibepollo/issues/224) | Upstream fixed | Closed upstream on 2026-06-09. Nimbus should still keep crash-safe state writes and recovery in scope. |
| [#223 Physical display setting unintended behavior](https://github.com/Nonary/Vibepollo/issues/223) | Upstream fixed | Closed upstream with `fixed` on 2026-06-12. Nimbus now leaves physical-target topologies unpinned except for explicit `ensure_only_display`, with unit coverage. |
| [#236 HEVC Main10/HDR not advertised despite `hevc_mode = 3`](https://github.com/Nonary/Vibepollo/issues/236) | Synced | Upstream 1.16.0-alpha.4 HDR/10-bit and NVENC API 12.1 fixes were cherry-picked into Nimbus after the 2026-05-23 upstream refresh. |
| [#238 Secondary monitor never recovers properly](https://github.com/Nonary/Vibepollo/issues/238) | Upstream fixed | Closed upstream in `v1.16.0-beta.2` with user confirmation. Keep as a Nimbus display-restore validation case before removing from release-risk tracking. |
| [#235 Windows 10 install fails due to PATH variables](https://github.com/Nonary/Vibepollo/issues/235) | Upstream fixed | Closed upstream as completed on 2026-05-24. Keep as a Nimbus installer validation case before removing from release-risk tracking. |
| [#237 Direct Steam Extension](https://github.com/Nonary/Vibepollo/issues/237) | Upstream fixed | Closed upstream as completed on 2026-05-24. Treat as a future product-scope comparison, not an immediate Nimbus task. |
| [#246 Auto-update selected release line](https://github.com/Nonary/Vibepollo/issues/246) | Upstream fixed | Opened after the previous radar snapshot and closed upstream as completed on 2026-05-24. Relevant only if Nimbus adopts Vibepollo's update-policy behavior. |
| [#255 Force Constant Capture not working except for version 1.15.4 stable](https://github.com/Nonary/Vibepollo/issues/255) | Upstream fixed | Closed upstream with `fixed` after the previous snapshot. Nimbus has the local cached-frame timeout equivalent in WGC dirty work; keep one constant-capture smoke case. |
| [#249 Installer deletes custom files when updating](https://github.com/Nonary/Vibepollo/issues/249) | Upstream fixed | Closed upstream after confirmation that installers above 1.15.5 avoid the deletion path. Nimbus should still preserve user-owned scripts and local glue during updates. |
| [#231 Low FPS issues while streaming](https://github.com/Nonary/Vibepollo/issues/231) | Upstream fixed | Closed upstream on 2026-06-08. Treat as performance smoke coverage unless new reports appear. |
| [#222 RTSP Error 54 after update](https://github.com/Nonary/Vibepollo/issues/222) | Upstream fixed | Closed upstream in `v1.16.0-beta.3`. Useful only as an upgrade regression smoke test unless Nimbus sees the same failure. |
| [#220 Session not closing after Playnite Fullscreen exit](https://github.com/Nonary/Vibepollo/issues/220) | Upstream fixed | Closed upstream in `v1.16.0-beta.3`. Keep in the launcher/session cleanup checklist, but no separate Nimbus task yet. |
| [#219 App override resolution defaults to unintended resolution](https://github.com/Nonary/Vibepollo/issues/219) | Upstream fixed | Closed upstream on 2026-06-11. Keep app-override resolution in profile validation. |
| [#181 PIN always successful](https://github.com/Nonary/Vibepollo/issues/181) | Upstream fixed | Closed upstream with `upstream bug` label on 2026-06-11. Track only if Nimbus diverges from inherited auth behavior. |
| [#174 Framestutter/choppy low-FPS content](https://github.com/Nonary/Vibepollo/issues/174) | Upstream fixed | Closed upstream on 2026-06-07. Keep frame-pacing checks hardware-specific. |
| [#152 No system tray icon](https://github.com/Nonary/Vibepollo/issues/152) | Upstream fixed | Closed upstream with `fixed` on 2026-06-12. Retain as a packaging/tray smoke case. |
| [#85 DRM Protected Content Error](https://github.com/Nonary/Vibepollo/issues/85) | Upstream fixed | Closed upstream on 2026-06-11. Keep as environment-sensitive support history, not active Nimbus work. |

## Docs And Support

| Issue | Bucket | Why |
| --- | --- | --- |
| [#276 Host Shortcuts Panel in WebUI](https://github.com/Nonary/Vibepollo/issues/276) | Docs/support | Couch-gaming shortcuts and text input are useful UX ideas, but they need security and interaction design before becoming a host reliability task. |
| [#254 Steam Controller support](https://github.com/Nonary/Vibepollo/issues/254) | Docs/support | New discussion points toward client-side Moonlight SDL controller mapping. Track as compatibility guidance, not a Nimbus host priority. |
| [#243 Tray icon update indicator](https://github.com/Nonary/Vibepollo/issues/243) | Docs/support | Useful release-notification UX, but not a launch reliability blocker. |
| [#232 Custom cover art for Playnite apps and app reordering](https://github.com/Nonary/Vibepollo/issues/232) | Docs/support | Useful UX request but not a launch blocker. |
| [#226 Mac version planned?](https://github.com/Nonary/Vibepollo/issues/226) | Docs/support | Closed upstream with an entitlement/cost explanation. Nimbus needs a clear platform-support statement rather than a port promise. |
| [#206 Custom app cover not loading in Artemis](https://github.com/Nonary/Vibepollo/issues/206) | Docs/support | May belong to host metadata/client compatibility, but starts as support triage. |
| [#188 WebRTC input on touch devices](https://github.com/Nonary/Vibepollo/issues/188) | Docs/support | WebRTC UX request. Relevant later, not first host stability pass. |
| [#29 Virus detected alerts](https://github.com/Nonary/Vibepollo/issues/29) | Docs/support | Updated upstream with SignPath/code-signing discussion. Nimbus release notes should separate binary reputation, code signing, and actual security claims. |
| [#245 Automatic restart after crash](https://github.com/Nonary/Vibepollo/issues/245) | Docs/support | Closed after the reporter confirmed automatic restart occurs but may take several minutes. Document expected recovery timing if Nimbus inherits similar service behavior. |
| [#216 Winuhid](https://github.com/Nonary/Vibepollo/issues/216) | Docs/support | Closed upstream because driver signing makes it unrealistic unless Sunshine carries it. Track only as an upstream dependency note. |

## Needs Hardware Or Volunteers

| Issue | Bucket | Why |
| --- | --- | --- |
| [#265 1.16.0 not working with dual-GPU](https://github.com/Nonary/Vibepollo/issues/265) | Needs hardware | Open with `logs requested` and multiple dual-GPU confirmations. Nimbus needs matching multi-GPU hardware to validate adapter selection, virtual display creation, and encoder choice. |
| [#172 AMD/AMF latency improvements](https://github.com/Nonary/Vibepollo/issues/172) | Needs hardware | Requires AMD GPU owners and repeatable latency measurements. |

## First Nimbus Backlog Candidates

1. Retained-session virtual display resume, especially HDR state stability on
   reconnect.
2. Detached command/session teardown cleanup, including screensaver state
   restoration.
3. Dual-GPU adapter selection and virtual display behavior once hardware is
   available.
4. WGC, UAC, tray, settings, and state-storage fixes that upstream has closed,
   kept as Nimbus validation cases before release.
5. Installer and updater preservation of user-owned files.
6. Remote-networking and WebRTC support boundaries.

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
