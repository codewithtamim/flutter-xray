## Contributing to flutter_xray

Thank you for considering a contribution. This document explains how to get started.

### Getting started

1. Fork this repository.
2. Clone your fork locally.
3. Create a new branch from main for your changes.

### Building

You need Flutter, Go, gomobile, and Python 3. To build the native libraries:

```bash
python3 scripts/build_and_wire.py
```

Then run the example:

```bash
cd example
flutter run
```

### Code style

- Follow the existing Dart, Kotlin, and Swift formatting.
- Run `flutter analyze` before committing. It should report zero issues.
- Run `flutter test` to make sure Dart tests pass.
- For Android, run `./gradlew :flutter_xray:testDebugUnitTest` inside `example/android`.

### Commit messages

We follow the Conventional Commits specification. Use one of these types:

- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes that do not affect code logic
- `refactor:` for code refactoring
- `test:` for adding or updating tests
- `chore:` for build, CI, or tooling changes

Keep the first line under 72 characters. Use the body to explain what and why, not how. If your change fixes an issue, add `Fixes #123` at the end of the body.

### Pull requests

- Keep each pull request focused on a single change.
- Write a clear title and description.
- If your change fixes an issue, mention the issue number.
- Do not include unrelated formatting changes in the same PR.

### What we are looking for

- Bug fixes
- Documentation improvements
- New API wrappers for libXray features that are not yet exposed
- Platform support improvements

### What we are not looking for

- VPN service implementations or TUN device managers inside this plugin. This package is meant to be a thin wrapper around Xray-core. Higher level VPN logic belongs in your app.

### Questions

If you are not sure whether a change is welcome, open an issue first and ask.
