# Contributing

Thank you for considering a contribution to Night of Assassins.

## Before you start

1. Search existing issues and pull requests so work is not duplicated.
2. For a significant feature or a change to game rules, open an issue first to discuss the intended behavior.
3. Keep changes focused. Avoid unrelated formatting or refactoring in the same pull request.

## Development setup

1. Install the Flutter stable SDK and Android tooling if you plan to run the Android app.
2. Clone the repository.
3. Generate the Android platform folder if needed:

   ```bash
   flutter create --platforms=android --org com.assassins.night --project-name night_of_assassins .
   ```

4. Fetch dependencies:

   ```bash
   flutter pub get
   ```

## Before opening a pull request

Run:

```bash
flutter analyze
flutter test
```

For UI changes, test on an Android emulator or device where possible and include screenshots or a short screen recording in the pull request.

## Pull request expectations

- Explain the problem and the approach.
- Link the issue being addressed, if applicable.
- Describe any user-visible behavior changes.
- Add or update tests for changed game rules and model behavior.
- Update the README or other documentation when setup, gameplay, or supported behavior changes.
- Do not commit API keys, signing keys, passwords, personal data, generated build output, or unrelated binary files.
- Confirm that you have the rights to contribute all code and assets in your change.

## Code and language

- Follow idiomatic Dart and the Flutter lints used by the project.
- Prefer clear names and small, focused methods.
- Preserve the Arabic right-to-left experience.
- Keep user-facing Arabic strings clear and consistent.
- Do not change game balance or role rules without describing the intended rule.

## Review

A maintainer may request changes, tests, or clarification before merging. Passing CI is necessary but does not by itself mean a change is ready to merge.
