# Nimbus Agent Instructions

Use repo-local instructions first: this file, README, docs, `.codeprism` briefs,
and project memory.

## Context Routing

When CodePrism is available, use it as the default context kernel:

```bash
codeprism prime "<task>" --changed
```

Read the generated `.brief.md` before broad file reads. Prefer targeted
`codeprism query`, `codeprism get`, `codeprism references`, and
`codeprism read --mode signatures|diff|map` before opening whole raw files.

Tool boundaries:

- CodePrism: context, graph, search, token savings, memory, recovery briefs.
- GSD: workflow orchestration, phases, execution, verification, audits, handoff.
- Superpowers: thinking methods, TDD, debugging, review discipline.
- Serena: optional exact semantic fallback for symbol/reference/refactor tasks.

Do not run Serena, GSD, or Superpowers as duplicate broad context scanners when
CodePrism is available. They should consume CodePrism briefs or targeted output.

## Local-First Rules

- Keep work local-first.
- Do not use external APIs, public pushes, destructive git commands, or
  migrations unless explicitly requested.
- Do not rewrite user changes.
- Keep benchmark and performance claims honest. Separate fixture benchmarks,
  local smoke tests, and field notes.

## Branch And Release Protocol

Nimbus intentionally does not mirror every upstream branch and tag into the
public namespace.

Recommended branches:

- `master` or `main`: active integration branch.
- `stable/<major>.<minor>`: maintained stable release line.
- `release/<major>.<minor>.<patch>`: temporary release prep branch.
- `feature/<topic>`: feature work.
- `fix/<topic>`: bug fixes.
- `docs/<topic>`: documentation-only work.

Nimbus tags must use the `nimbus-` prefix:

- `nimbus-v0.1.0-alpha.1`
- `nimbus-v0.1.0-beta.1`
- `nimbus-v0.1.0`
- `nimbus-v0.1.1`

Do not run `git push --tags` casually. Upstream Vibepollo, Apollo, and Sunshine
tags are history references, not Nimbus releases.

## Upstream Remotes

Use these remotes when present:

- `origin`: `https://github.com/kunolabs/Nimbus.git`
- `upstream-vibepollo`: `https://github.com/Nonary/Vibepollo.git`
- `upstream-apollo`: `https://github.com/ClassicOldSong/Apollo.git`
- `upstream-sunshine`: `https://github.com/LizardByte/Sunshine.git`

Before syncing from upstream, document the source branch or tag, base commit,
expected conflicts, and validation plan.

## Completion Bar

For each completed task pass:

- Update relevant docs when behavior, workflow, or public expectations change.
- Record branch, base commit, changed files, verification, and residual risk in
  the final summary.
- Prefer a focused commit for each coherent pass when the user asks to commit.
