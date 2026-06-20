# Contributing to Nimbus

Thank you for helping improve Nimbus. This project is a downstream host fork with
a large upstream history, so the best contributions are focused, testable, and
easy to review.

## Before You Start

- Search existing issues and pull requests before opening a duplicate.
- Open an issue first for large features, risky refactors, packaging changes, or
  behavior that affects pairing, authentication, input, capture, or streaming.
- Keep pull requests small enough that maintainers can understand the behavior
  change without reverse-engineering the whole subsystem.
- Preserve upstream attribution and license headers.

## Development Setup

Clone the repository with submodules:

```bash
git clone https://github.com/kunolabs/Nimbus.git --recurse-submodules
cd Nimbus
```

Follow the platform-specific build notes in [building.md](building.md).

Typical local build:

```bash
cmake -B build -G Ninja -S .
ninja -C build
```

## Project Areas

### Host Core

The native host code lives mainly under `src/`, with build configuration in
`cmake/` and top-level CMake files. Changes here can affect streaming behavior,
input, capture, authentication, networking, and packaging, so include clear test
notes.

### Web UI

The Web UI lives under `src_assets/common/assets/web`.

- Vite is used for the Web UI build.
- Vue powers interactive pages.
- Tailwind CSS is the preferred styling system.
- Legacy classes may still exist through compatibility shims. Prefer moving new
  UI work toward first-class Tailwind utilities.
- If you add files outside the existing Web UI tree, update `tailwind.config.js`
  so classes are not purged.
- For visible redesign work, start with
  [ui-identity-plan.md](ui-identity-plan.md) and keep changes in small,
  screenshot-backed slices.

### Documentation

Documentation lives in the root and under `docs/`. Nimbus is still early in its
public rebrand, so docs should be explicit when a command, path, binary, or log
still uses an upstream name.

## Pull Request Expectations

Every pull request should include:

- A clear summary of what changed.
- Why the change is needed.
- How the change was tested.
- Screenshots or short clips for visible UI changes.
- Any known limitations or follow-up work.

Keep commits focused. A documentation cleanup, a packaging fix, and a streaming
behavior change should usually be separate pull requests.

## Testing

Use the narrowest test set that proves the change.

Recommended checks:

```bash
cmake -B build -G Ninja -S .
ninja -C build
```

If tests are enabled and built:

```bash
./build/tests/test_sunshine
```

Some inherited binaries and test names still use upstream names. Do not rename
runtime artifacts in the same pull request as a behavior change unless the PR is
specifically a rebrand pass.

For formatting C/C++ sources, use the inherited `.clang-format` configuration.
The helper below modifies files:

```bash
python ./scripts/update_clang_format.py
```

## AI-Assisted Contributions

AI-assisted work is allowed, but it must be treated like any other authored code.

If you use AI tools:

- Review every generated line before submitting.
- Understand the behavior well enough to explain it in review.
- Validate the change manually or with tests.
- Do not submit generated tests as proof unless you have checked that they test
  the real behavior.
- Mention meaningful AI assistance in the pull request when it affects design,
  code, or test generation.

Maintainers may request a smaller patch, additional test evidence, or a manual
reproduction note if a contribution is difficult to audit.

## Security-Sensitive Changes

Changes involving authentication, pairing, API tokens, Web UI sessions, network
listeners, installer privileges, update checks, log export, or crash bundles need
extra care. Keep those pull requests small and include a threat-oriented note in
the PR description.

Do not include secrets, private certificates, tokens, personal hostnames, public
IP addresses, or private logs in issues or pull requests.

## Upstream Relationship

Nimbus tracks a living upstream ecosystem. When a change is copied, adapted, or
inspired by upstream work, note the source in the pull request. When a fix could
help upstream users, maintainers may ask for a form that can be upstreamed cleanly.

## Community Conduct

Be direct, kind, and technical. Assume other contributors are trying to help.
Project discussions should stay focused on reproducible behavior, reviewable
changes, and user impact.
