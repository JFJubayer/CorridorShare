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

## Increments Delivered & Verified (CSE-3102)

All four course increments have been built, rigorously tested, and verified:

1. **Increment 1 — Trips, Parcels, and Routing Foundation**:
   - Bangladesh 64-districts dataset (`core/constants/bangladesh_districts.dart`).
   - Clean Architecture domain models, status lifecycles, and use cases for trips and parcels.
   - Prohibited items declaration verification and form validations.
   - Home dual-feed and My Posts tabs.
   - [docs/increment_1.md](docs/increment_1.md)

2. **Increment 2 — Matching, Offers, and Realtime Chat**:
   - Corridor route, deadline, capacity, and traveller no-carry restriction matching engine.
   - Bidirectional offer and counter-offer negotiation state machine.
   - Parcel status integration (`matched` on offer acceptance).
   - Realtime offer-linked message stream and chat composer.
   - [docs/increment_2.md](docs/increment_2.md)

3. **Increment 3 — Verification & Delivery Tracking**:
   - Pickup proof capture with condition checklist and photo verification (`inTransit`).
   - Two-Factor delivery verification via 4-digit recipient PIN (`delivered`).
   - Dispute reporting mechanism (`disputed`).
   - Real-time 3-stage delivery timeline tracking widget.
   - [docs/increment_3.md](docs/increment_3.md)

4. **Increment 4 — Demo Wallet, Reviews, and Admin Oversight**:
   - Demo-only simulated BDT wallet with ledger history, top-up actions, and escrow lifecycle.
   - Peer ratings (1–5 stars) and review feedback.
   - Administrative KPI dashboard and dispute escalation queue with refund/payout actions.
   - [docs/increment_4.md](docs/increment_4.md)

### Verification & Testing Status

```bash
flutter analyze   # 0 issues found
flutter test      # 119/119 tests passing (100%)
```

## Contributing

Open an issue or branch off `main`. Run `flutter analyze` and `flutter test`
locally before pushing. Keep PRs small, well-tested, and adhering to Clean Architecture.