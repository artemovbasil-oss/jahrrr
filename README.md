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
flutter run --dart-define=SUPABASE_URL=your-project-url --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Supabase configuration

The app uses Supabase for authentication and storage. Provide the URL and anon key via `--dart-define` (do not commit keys).

```bash
flutter run --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \\
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## UX direction

- Light, minimal dashboard inspired by tools like Notion.
- Material 3 components with soft surfaces and bold stats.
- Dashboard focus: clients, budgets, milestones, payments, deadlines.
