# PennyPilot

PennyPilot is a cross-platform personal finance Flutter application for tracking income, expenses, budgets, and categories. It provides a clean dashboard, monthly summaries, and simple transaction management to help users understand and control their spending.

This repository contains the Flutter source code and multi-platform configuration (Android, iOS, web, macOS, Windows, Linux).

Key features
- User authentication (register / login)
- Add, edit and delete transactions
- Categorize transactions and manage categories
- Budget overview and tracking
- Monthly view and dashboard with summaries
- Settings and account management

Screenshot / Demo
> Add screenshots or a short demo GIF here (assets/screenshots). Example:

![PennyPilot Dashboard](docs/screenshots/dashboard.png)

Getting started (developer)
1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Enable the platforms you need (Android/iOS/web/desktop). Example to enable Windows and web:

```powershell
flutter channel stable
flutter upgrade
flutter config --enable-windows-desktop
flutter config --enable-web
```

3. Fetch dependencies:

```powershell
Set-Location -LiteralPath 'D:\Flutter Projects\pennypilot'
flutter pub get
```

4. Run the app (choose a device or emulator):

```powershell
flutter devices                # list available devices
flutter run -d <device_id>     # run on a specific device
```

Build for release
- Android (APK):

```powershell
flutter build apk --release
```

- Android (AAB):

```powershell
flutter build appbundle --release
```

- iOS (requires macOS and Xcode):

```bash
flutter build ios --release
```

- Web:

```powershell
flutter build web --release
```

Testing

```powershell
flutter test
```

Common developer tasks
- Analyze the project:

```powershell
flutter analyze
```

- Format code:

```powershell
flutter format .
```

Repository and Git
- This project is intended to be hosted on GitHub. Add a remote and push:

```powershell
git remote add origin https://github.com/<USERNAME>/PennyPilot.git
git branch -M main
git push -u origin main
```

Notes on secrets and keys
- Do NOT commit sensitive files to the repository. Common files to keep out of version control:
  - `local.properties` (Android SDK path)
  - Android keystore files and passwords
  - Any files that contain API keys or credentials

CI / GitHub Actions (optional)
Here's a minimal example workflow to run tests on push (.github/workflows/flutter.yml):

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
	runs-on: ubuntu-latest
	steps:
	  - uses: actions/checkout@v4
	  - uses: subosito/flutter-action@v2
		with:
		  flutter-version: 'stable'
	  - name: Install dependencies
		run: flutter pub get
	  - name: Run tests
		run: flutter test --coverage
```

Contributing
- Please open issues for bugs or feature requests.
- For code contributions, fork the repo, create a feature branch, then open a pull request. Follow these guidelines:
  1. Keep changes focused and small
  2. Run `flutter format` and `flutter analyze` before submitting
  3. Add/update tests where appropriate

License
- This repository currently has no license file. If you want to make the project open-source, consider adding an MIT or Apache-2.0 `LICENSE` file. Example: `MIT`.

Contact
- Maintainer: add your name and contact (GitHub profile or email)

Project structure (high level)
- `lib/` — Dart source code (views, controllers, models, widgets)
- `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/` — platform folders
- `test/` — unit and widget tests

Further notes
- If you want, I can:
  - Add example screenshots to `docs/screenshots/` and update this README
  - Create a `LICENSE` file (MIT) and a basic GitHub Actions workflow file
  - Help prepare Play Store / App Store release instructions

Enjoy working on PennyPilot! If you'd like, tell me which tasks above you want me to do next and I will make the changes.
