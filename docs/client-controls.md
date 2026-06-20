# Client Controls

Nimbus keeps compatibility with Moonlight-compatible clients while exposing a
few host-side controls for pairing, permissions, display overrides, and client
commands.

## Permission System

Each paired client can be allowed or restricted from sensitive host actions. Use
the PIN page to review paired devices, remove a single device, or unpair all
devices when access should be reset.

Recommended maintainer posture:

- Treat unknown paired devices as untrusted.
- Unpair devices before sharing logs, fixtures, or VM images.
- Re-pair clients after major host, certificate, or credential changes.

## Display Mode Override

Display mode override lets a client request a fixed resolution and refresh rate
for streams where the automatic client-requested mode is not the desired host
mode.

Use the format:

```text
1920x1080x60
```

Leave the field blank to use the client's requested mode. Record any override
used in bug reports, because display selection, HDR, virtual displays, and
physical monitor recovery can all affect the final stream mode.

## Client Commands

Client commands allow a paired client to trigger configured host commands when a
session connects or disconnects.

Use this carefully:

- Keep commands local and explicit.
- Avoid commands that depend on private paths when sharing configurations.
- Prefer scripts stored beside the app or inside a documented tools directory.
- Disable client commands for devices that should only launch apps.

Nimbus inherits much of this behavior from the Apollo and Sunshine lineage. This
page is the Nimbus-owned reference surface for these controls while deeper docs
are rebuilt.
