# Release Notes

Create one Markdown file per Nimbus release tag before pushing the tag.

Nimbus release tags use the `nimbus-v` prefix:

```text
nimbus-v0.1.0-alpha.1
nimbus-v0.1.0-beta.1
nimbus-v0.1.0
nimbus-v0.1.1
```

Prefer an exact notes file that includes the full tag:

```text
release_notes/nimbus-v0.1.0-alpha.1.md
```

The workflow also accepts `release_notes/0.1.0-alpha.1.md` after removing the
`nimbus-v` prefix, but the exact full-tag filename is clearer for Nimbus
maintenance.

Draft release notes should live under `release_notes/drafts/`. The release
workflow only checks top-level matching files, so keeping drafts nested avoids
accidentally satisfying the release-note gate before fixture validation passes.

Tag suffixes determine release type:

- Stable: unsuffixed semantic versions like `nimbus-v0.1.0`, or tags that
  include `stable`.
- Pre-release: `alpha`, `beta`, or `rc`, optionally followed by `.` or `-`
  metadata such as `alpha.1` or `rc-1`.

The workflow publishes GitHub releases with titles like `Nimbus v0.1.0-alpha.1`
and uploads a versioned installer asset such as
`NimbusSetup-v0.1.0-alpha.1.exe`.

If no matching notes file exists in the tagged commit, the release flow skips
instead of publishing generic generated notes.
