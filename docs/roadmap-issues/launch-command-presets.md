# Tracking: Launch Command Presets

Public tracker: pending

Maintainer note: this is a QoL backlog item discovered during the Apollo to
Nimbus switch test. It should stay smaller than Game Discovery Inbox and focus
on making existing app entries easier to create and understand.

## Problem

Many community Sunshine, Apollo, and Vibepollo setups use detached commands to
launch games through Steam or another launcher while keeping the stream alive.
The raw command editor works, but it expects users to already know the correct
URI or wrapper command.

Examples include:

- Steam AppID launches such as `steam://rungameid/3357650`.
- Steam Big Picture launches for TV-first clients.
- Playnite fullscreen or per-game launch flows.
- Launcher URL schemes for Epic, Ubisoft Connect, EA App, and Battle.net.
- Pre/post wrappers for RTSS, display mode changes, HDR setup, or cleanup.

## Goal

Add a small preset picker beside detached commands so Nimbus can generate
common launch commands while still showing the final command before save.

## Proposed Scope

### Phase 1: Steam Presets

- Add `Add Preset` beside detached commands in the application editor.
- Support `Steam game` input as:
  - raw AppID,
  - `steam://rungameid/<appid>`,
  - Steam store URL.
- Generate a detached command and leave the primary command empty unless the
  user already entered one.
- Keep the generated command editable.

### Phase 2: TV And Launcher Presets

- Add `Steam Big Picture`.
- Add Playnite fullscreen launcher preset.
- Document launcher URL patterns that are safe and tested.

### Phase 3: Advanced Wrappers

- Add optional before/after command templates for frame caps, display/HDR setup,
  and cleanup.
- Require fixtures before shipping wrappers that change system state.

## Acceptance Criteria

- Presets never overwrite an existing command without confirmation.
- Generated commands are visible before saving.
- Raw command editing remains available.
- Steam AppID, Steam URL, and `steam://rungameid/...` input normalize to the same
  command.
- Documentation includes at least one Shield TV / Steam game test note.

## References

- `docs/community-research.md`
- `docs/roadmap-issues/setup-doctor-client-profiles.md`
