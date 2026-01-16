# Jahrrr

CRM for designers to track clients, budgets, milestones, payments, deadlines, and analytics.

## Getting started

1. Install Flutter (stable channel).
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

## Local testing

### Run on Android emulator

1. Install Android Studio + Android SDK.
2. Create an emulator in **Tools > Device Manager**.
3. Start the emulator, then run:

```bash
flutter run
```

### Run on iOS simulator (macOS only)

1. Install Xcode and Xcode command line tools.
2. Open the simulator:

```bash
open -a Simulator
```

3. Run the app:

```bash
flutter run
```

### Run on Web

1. Enable web support (one-time):

```bash
flutter config --enable-web
```

2. Run the app in Chrome:

```bash
flutter run -d chrome
```

### Helpful checks

```bash
flutter analyze
flutter test
```

## UX direction

- Light, minimal dashboard inspired by tools like Notion.
- Material 3 components with soft surfaces and bold stats.
- Dashboard focus: clients, budgets, milestones, payments, deadlines.
