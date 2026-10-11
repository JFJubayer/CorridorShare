# CorridorShare (Flutter, Firebase)

A peer-to-peer crowd-shipping app for Bangladesh. Senders post parcels, travelers
post trips, they agree on a price, the traveler delivers.

This subproject is the **Firebase** variant. The sibling `corridorshare-app/`
uses Supabase. They share product intent but live on separate stacks so we can
evaluate both during the CSE-3102 sprint.

## Tech

- Flutter (stable), Dart 3.12, Material 3
- Riverpod for state, go_router for routing
- freezed + json_serializable for models
- Firebase: Auth (phone OTP), Firestore, Storage, Cloud Functions, FCM
- `flutter_localizations` + ARB (`en`, `bn`)

## Folder layout

```text
lib/
  main.dart            // bootstraps Firebase and ProviderScope
  app.dart             // MaterialApp.router + theme + l10n
  core/                // theme, router, l10n, errors, utils, firebase bootstrap
  features/            // one folder per feature
    auth/
      domain/          // entities, repository interfaces, use cases
      data/            // DTOs, datasources, repository impls
      presentation/    // widgets + Riverpod notifiers
    home/ my_posts/ chats/ profile/
test/
  core/ features/
tool/
  run_emulators.sh     // Firebase emulator suite
firestore.rules        // deny-by-default + users/{uid} + admin claim
storage.rules          // NID path only
firebase.json
```

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The app boots without a Firebase project. To wire Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
flutter run --dart-define=FIREBASE_ENABLED=true
```

Local emulators:

```bash
tool/run_emulators.sh
```

## CI

`.github/workflows/corridorshare-mobile-ci.yml` runs `flutter pub get`,
`build_runner build`, `flutter analyze`, and `flutter test` on every push and
PR that touches `corridorshare/**` or the workflow file. The workflow is
co-located inside this subproject for review and will be hoisted to the
monorepo's `.github/workflows/` when the team is ready to enable it.

## Foundation status (Increment 1)

- Project skeleton, theme, go_router shell with bottom nav (Home, My posts,
  Chats, Profile).
- Localization for `en` and `bn`.
- Phone OTP shape (validation, use cases, fake auth controller) with widget
  tests.
- Firebase emulator config and bootstrap helper that respects the
  `FIREBASE_ENABLED` dart-define.
- Firestore and Storage security rules: deny-by-default with the user-self
  and admin-claim helpers scaffolded.

See `docs/foundation.md` for the full QA log and Increment 1 next tasks.

## Contributing

Open an issue or branch off `main`. Run `flutter analyze` and `flutter test`
locally before pushing. Keep PRs small and tied to a single feature slice.