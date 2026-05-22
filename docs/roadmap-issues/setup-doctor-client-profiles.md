# Roadmap: Nimbus Setup Doctor And Client Profiles

## Problem

Nimbus should not compete with Vibepollo by adding another pile of hidden
toggles. Community setup pain is mostly about knowing which settings matter for
a specific host/client setup and how to diagnose failures.

Users repeatedly struggle with:

- virtual display and HDR state,
- frame pacing and refresh-rate mismatches,
- audio sink/channel routing,
- ViGEm/controller conflicts,
- persistent or missing cursors,
- LAN/WAN/Tailscale/WireGuard path confusion,
- Playnite/library import expectations,
- unsigned installer and driver trust.

## Goal

Make Nimbus the guided, validated, profile-driven host fork:

> Tell Nimbus what you stream to, and Nimbus tells you the correct display,
> bitrate, audio, controller, and network setup. If something is wrong, Nimbus
> explains why.

## Proposed Scope

### Phase 1: Read-Only Setup Doctor

- Show GPU/encoder summary.
- Show active capture/display target and virtual display status.
- Show HDR/10-bit capability and current stream setup when available.
- Show ViGEm/SudoVDA presence and warnings.
- Show selected audio sink and channel mode.
- Show basic firewall/port checks.
- Show current log bundle/export entry point.
- Add a Cursor Doctor troubleshooting card.

### Phase 2: Client Profiles

- Add known setup profiles for:
  - Shield TV / Android TV 4K60,
  - Shield TV / Android TV 4K120 where supported,
  - Steam Deck / handheld,
  - phone/tablet,
  - mini PC client,
  - headless Windows host,
  - remote Tailscale/WireGuard.
- Start as recommendations and docs before automatic config writes.

### Phase 3: Game Discovery Inbox

- Present read-only game/app candidates from known sources.
- Prefer Playnite and launcher manifests over blind `.exe` scanning.
- Let users select/deselect/all/none before importing.
- Track imported batch metadata so users can undo.

## Acceptance Criteria

- First pass is safe to run on an existing Apollo/Vibepollo/Nimbus config.
- No automatic config writes happen without an explicit confirm step.
- Each warning includes a concrete next action.
- Fixture matrix records at least one real Shield TV / Artemis stream result.
- Documentation links back to `docs/community-research.md`.

## References

- `docs/community-research.md`
- `docs/upstream-issue-radar.md`
- `docs/windows-installer-fixture.md`
- `docs/naming-identity-audit.md`
