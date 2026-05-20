# Security Policy

Nimbus handles host streaming, local network services, pairing, input, capture,
configuration, and Web UI access. Please treat security issues carefully.

## Supported Versions

Nimbus has not published a Nimbus-branded stable release yet. During the
bootstrap period, security fixes will target the `master` branch unless a release
branch is created later.

| Version | Supported |
| --- | --- |
| `master` | Best effort |
| Nimbus stable releases | Not yet published |
| Upstream Vibepollo/Apollo/Sunshine releases | Report upstream unless the issue is specific to this fork |

## Reporting a Vulnerability

If GitHub private vulnerability reporting is enabled for this repository, use it.
If it is not enabled, open a minimal public issue asking for maintainer contact
without posting exploit details.

Please include:

- Affected commit or release.
- Host OS and version.
- Whether the issue requires local network access, local user access, paired
  client access, Web UI access, or no authentication.
- High-level impact.
- Safe reproduction steps, if available.

Do not include:

- Live credentials, API tokens, private certificates, or pairing secrets.
- Public IP addresses or private hostnames.
- Full logs that contain secrets or personal paths.
- Weaponized exploit code in a public issue.

## Scope

Security-sensitive areas include:

- Pairing and client trust.
- API token handling and authorization.
- Web UI authentication, session cookies, and CSRF boundaries.
- Network listeners and request parsing.
- Installer privilege behavior.
- Update checks and release artifact trust.
- Log export and crash bundle contents.
- File path handling in app launch, Playnite sync, and helper tools.

## Expectations

This project does not currently run a bug bounty program. Maintainers will try to
acknowledge serious reports promptly, reproduce them, and publish fixes with
clear release notes when a Nimbus release channel exists.
