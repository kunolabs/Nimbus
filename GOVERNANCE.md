# Governance

Nimbus is currently maintained as a benevolent-maintainer fork.

## Maintainer Role

The maintainer is responsible for:

- Setting project direction.
- Reviewing and merging pull requests.
- Deciding release readiness.
- Coordinating upstream syncs.
- Handling security reports.
- Keeping public documentation honest and current.

## Decision Making

Nimbus favors small, reversible decisions backed by reproducible evidence.

For routine changes, maintainer review is enough. For larger changes, the project
should use an issue or design note before implementation.

Large changes include:

- Rebranding binaries, package IDs, services, certificates, or config paths.
- Authentication, pairing, token, or network boundary changes.
- Installer privilege changes.
- Capture pipeline changes.
- Virtual display lifecycle changes.
- Release automation changes.

## Release Channels

Nimbus has not published branded releases yet. The intended release model is:

- `alpha`: early testing, may break.
- `beta`: feature-complete candidate for wider testing.
- `stable`: recommended for most users after real-world validation.

Release notes should separate inherited upstream changes from Nimbus-specific
changes.

Nimbus tags use the `nimbus-` prefix, such as `nimbus-v0.1.0-alpha.1` or
`nimbus-v0.1.0`, so they are never confused with inherited upstream tags.

## Upstream Sync Policy

Nimbus should keep explicit remotes or documented references for:

- Nonary/Vibepollo.
- ClassicOldSong/Apollo.
- LizardByte/Sunshine.

Syncs should be reviewed as their own work whenever possible. Avoid mixing a
large upstream merge with unrelated Nimbus feature work.

## AI-Assisted Maintenance

AI tools may be used to speed up implementation, review, documentation, and test
planning. Maintainers remain responsible for the code. AI output is not a
substitute for understanding, review, or validation.
