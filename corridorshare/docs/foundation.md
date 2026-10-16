# Foundation — Increment 1 deliverable

Status: foundation slice merged
Last reviewed: 2026-10-11

This document records what shipped in the foundation slice, what was
assumed, what verification ran, and the three next tasks for the team.

## What was built

- **Project skeleton** following Clean Architecture, feature-first.
  `lib/core/` (theme, router, l10n, errors, utils, firebase bootstrap)
  and `lib/features/` with one folder per feature split into
  `domain/`, `data/`, `presentation/`.
- **Material 3 theme** with light and dark variants, brand-tinted
  `ColorScheme.fromSeed`, and tuned component themes for cards, inputs,
  buttons, and the bottom navigation bar.
- **Routing** with `go_router`. `StatefulShellRoute.indexedStack` hosts
  the four bottom-nav tabs (Home, My posts, Chats, Profile). An `/auth`
  route plus `/auth/otp` live outside the shell. A redirect keeps
  unauthenticated users on `/auth` and authenticated users on the shell.
- **Localization** for `en` and `bn` via `flutter_localizations` + ARB,
  generated into `lib/l10n/generated/`. A Riverpod `LocaleController`
  exposes the language switch in the profile tab.
- **Core utilities**: a sealed `Failure` hierarchy and a `Result<T>`
  return type used at repository boundaries.
- **Auth feature**:
  - `PhoneNumber` value object with Bangladesh-aware validation
    (E.164 or local form, digit-only).
  - `AuthUser` and `UserDto` (freezed) entities.
  - `AuthRepository` interface with `RequestOtp` and `VerifyOtp` use
    cases that validate before touching the data layer.
  - `AuthDataSource` interface and a `FakeAuthDataSource` for tests
    and the foundation boot path.
  - `PhoneEntryPage` and `OtpVerificationPage` widgets backed by
    Riverpod notifiers.
- **Firebase scaffold**:
  - `firebase.json` with the emulator suite (auth 9099, firestore 8080,
    storage 9199, functions 5001, pubsub 8085, UI 4000).
  - `firestore.rules` deny-by-default with the user-self and admin
    claim helpers scaffolded. Wallet writes are explicitly denied from
    the client.
  - `storage.rules` deny-by-default; only `users/{uid}/nid/{file}` is
    open to the owner.
  - `firestore.indexes.json` (empty).
  - `lib/core/firebase/firebase_bootstrap.dart` is opt-in via
    `--dart-define=FIREBASE_ENABLED=true`. The default off-switch lets
    `flutter run` and CI work without a live Firebase project.
  - `tool/run_emulators.sh` to start the emulator suite locally.
- **Lint and analysis**: stricter rules in `analysis_options.yaml`
  (const discipline, single quotes, trailing commas, sort directives,
  prefer super parameters, full hex colors).
- **CI workflow**: `.github/workflows/corridorshare-mobile-ci.yml`
  co-located in the subproject for review. It runs `pub get`,
  `build_runner build`, `flutter analyze`, and `flutter test` on every
  push or PR that touches `corridorshare/**`. The workflow is intended
  to be hoisted to the monorepo's `.github/workflows/` directory when
  the team is ready — current sandbox cannot write outside the
  subproject.
- **Documentation**: `README.md` rewritten for the subproject.

## What was assumed

- Flutter stable (3.44.6) and Dart 3.12 are the supported toolchain.
- The team will use `flutterfire configure` to generate
  `firebase_options.dart` locally; that file is **not** committed.
- No secrets will be committed. CI does not require any.
- One Firebase project id, `corridorshare-dev`, is used as the default
  in `.firebaserc`. Real project ids will replace it.
- The auth OTP delivery itself is wired in the next slice. This
  foundation lays the shape; the data source is the fake.

## Verification (run on 2026-10-11)

- `flutter pub get` resolves.
- `dart run build_runner build --delete-conflicting-outputs` regenerates
  freezed and json_serializable code without errors.
- `flutter analyze` reports **0 issues** (lints, types, and
  directives_ordering all clean).
- `flutter test` reports **25 passed, 0 failed**:
  - `core/errors/failure_test.dart` (3)
  - `core/utils/result_test.dart` (4)
  - `features/auth/domain/entities/phone_number_test.dart` (7)
  - `features/auth/domain/usecases/request_otp_test.dart` (3)
  - `features/auth/domain/usecases/verify_otp_test.dart` (3)
  - `features/auth/presentation/pages/phone_entry_page_test.dart` (5)
  - `widget_test.dart` (1 smoke)
- `flutter build linux --no-pub` produces a release bundle.
- `dart fix --apply` is clean.

## Three next tasks

1. **Increment 1, part 2 — wire Firebase Phone OTP.** Add
   `FirebaseAuthDataSource`, generate `firebase_options.dart` via
   `flutterfire configure`, and gate the override in `main.dart` on
   `FIREBASE_ENABLED=true`. Add an `integration_test` that exercises
   the emulator-driven OTP flow.
2. **Increment 1, part 3 — post a trip and a parcel.** Implement
   the `trips` and `parcels` features (domain, data, presentation)
   along with the no-carry list, prohibited-items declaration, and
   profile basics. Move profile verification flag off placeholder.
3. **Increment 2 — match and chat.** Add the `matching` and `chat`
   features. Matching excludes parcels blocked by the traveller's
   no-carry list and surfaces that list before the sender accepts.
   Chat is bound to deals and uses Firestore listeners, with messages
   stored under `deals/{id}/messages`.

## Auth bypass (interim, 2026-10-11)

While we focus on the first product features, the auth feature is parked
but the code is kept. The router boots directly into the bottom-nav shell
at `/home`, no redirect is wired, and `/auth` plus `/auth/otp` remain
reachable from the profile tab as a "Sign in" tile. The phone entry page
calls `context.go('/auth/otp')` after a successful `requestOtp` so the
flow still works without the redirect.

To re-enable auth gating when Firebase Phone OTP is wired in:

- Restore the `redirect` and `refreshListenable` block in
  `appRouterProvider` (the foundation commit has the original code).
- Move `authDataSourceProvider.overrideWith(FakeAuthDataSource())` out
  of `main.dart` and into test `ProviderScope` overrides.
- Update the smoke test "boots into the bottom-nav shell by default" to
  assert the opposite (it should land on `/auth`).

## Risks and follow-ups

- **CI hoisting**: the workflow file is inside the subproject for now.
  The team should move it to the monorepo's `.github/workflows/`
  before enabling it.
- **Bangla font**: Material 3 ships Roboto. For low-end Android we
  should bundle `NotoSansBengali` and reference it from `AppTheme`.
  Tracked in a follow-up.
- **Firebase free tier**: emulator usage is local; production
  authenticator costs come in Increment 3 with FCM and Cloud Functions.
- **No real money**: per the brief, wallet is a demo. Increment 3 will
  pin this in the wallet domain entity and the security rules.
