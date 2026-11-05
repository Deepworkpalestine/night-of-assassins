# Night of Assassins (ليلة المغتالين)

[![CI](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/ci.yml)
[![Build Android APK](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/build-apk.yml/badge.svg?branch=main)](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/build-apk.yml)

**Night of Assassins** is an Arabic, local pass-and-play social-deduction game built with Flutter. Players share one device during role handoff, night actions, discussion, and voting.

> **Project status:** Active development. The repository currently has no tagged stable release. Android APKs are built by GitHub Actions and made available as workflow artifacts; tagged releases are published automatically.

## Features

- Arabic, right-to-left interface.
- Local group play on a shared device.
- Configurable player and Mafia team counts.
- Optional special roles and role-specific night actions.
- Hand-off and private role-reveal flow between players.
- Night resolution, discussion, voting, tie revotes, and game-end conditions.
- Optional role reveal after elimination and vote-detail settings.
- Android release APK build through GitHub Actions.

## Roles

| Team | Roles |
| --- | --- |
| Citizens | Citizen, Doctor, Detective, Bodyguard, Hunter |
| Mafia | Mafia, Godfather, Spy, Silencer |
| Independent | Jester, Gambler |

Role availability and game balance depend on the selected player count and settings.

## Technology

- Flutter and Dart
- Riverpod for state management
- `shared_preferences`
- `audioplayers`
- Android APK packaging through GitHub Actions

## Run locally

### Requirements

- Flutter SDK on the stable channel
- Dart SDK compatible with the constraint in pubspec.yaml
- Android SDK and an Android device/emulator for Android runs

This repository generates the Android platform folder during CI instead of committing generated Android scaffolding. From the repository root, run:

```bash
flutter create --platforms=android --org com.assassins.night --project-name night_of_assassins .
flutter pub get
flutter run
```

To build a release APK locally:

```bash
flutter build apk --release
```

## Tests and code quality

Run the same checks used by the continuous-integration workflow:

```bash
flutter pub get
flutter analyze
flutter test
```

The CI workflow runs on pushes to main, pull requests targeting main, and manual dispatches.

## Android APK from GitHub Actions

1. Open the [Build Android APK workflow](https://github.com/Deepworkpalestine/night-of-assassins/actions/workflows/build-apk.yml).
2. Open the latest successful run.
3. Download the night-of-assassins-android-apk artifact.
4. Extract the archive to find the APK and its SHA-256 checksum.

Workflow artifacts expire after 30 days. To publish a durable GitHub Release, push a version tag:

```bash
git tag v1.3.0
git push origin v1.3.0
```

The release workflow builds the APK and attaches it, together with its checksum, to the GitHub Release.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request. Bug reports should include clear reproduction steps and device/Flutter details. Changes to game rules should explain the intended behavior and include tests where practical.

The project follows the [Code of Conduct](CODE_OF_CONDUCT.md). Security issues should be reported privately as described in [SECURITY.md](SECURITY.md).

## License and third-party assets

Original project source code and project documentation are offered under the MIT License; see [LICENSE](LICENSE). **The MIT license does not cover the files under assets/ or third-party materials.** Their origin and redistribution terms must be checked separately. See [ASSET-LICENSES.md](ASSET-LICENSES.md) before reusing or redistributing images, fonts, or audio.

## العربية

**ليلة المغتالين** لعبة جماعية عربية من نوع الاستنتاج الاجتماعي، مبنية باستخدام Flutter، وتعمل بنظام اللعب المحلي التمريري على جهاز واحد. يتناوب اللاعبون على استلام الجهاز لكشف أدوارهم سرًا، ثم تنفيذ إجراءات الليل والنقاش والتصويت.

تشمل الأدوار الحالية: المواطن، الدكتور، المحقق، الحارس، الصياد، المافيا، العرّاب، الجاسوس، الكاتم، المهرج، والمراهن.

لبدء التطوير محليًا، ثبّت Flutter ثم نفّذ أوامر إنشاء منصة Android وجلب الاعتماديات الموضحة أعلاه. لفحص الجودة شغّل flutter analyze وflutter test.

المساهمات مرحّب بها وفق [دليل المساهمة](CONTRIBUTING.md). يرجى مراجعة [ملف تراخيص الأصول](ASSET-LICENSES.md)؛ ترخيص MIT يغطي كود المشروع الأصلي والوثائق فقط ولا يمنح تلقائيًا حقوق إعادة توزيع الخطوط أو الصور أو المؤثرات الصوتية.
