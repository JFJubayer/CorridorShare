# CorridorShare mobile

Flutter client for CorridorShare. Android and iOS are the supported release targets.

## Requirements

- Flutter `3.41.6` (the stable SDK revision recorded in `.metadata` and used by CI)
- A Supabase project created from the root `supabase/` directory

## Runtime modes

Supabase is the default and required production mode:

```sh
flutter run \
  --dart-define=DATA_MODE=supabase \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

Local demo mode is explicit and is rejected by release builds:

```sh
flutter run --dart-define=DATA_MODE=demo
```

Never commit service-role keys or mobile signing secrets.

In live mode, trips, packages, deals, and messages use the Supabase adapter.
Escrow lock, delivery OTP issue, and release use database RPCs. Mobile-wallet
top-ups stay disabled until a provider-confirmed server payment flow is added.
The demo adapter is only for local development and tests.

## Organization

- `lib/core/`: configuration, theme tokens, validation, and typed money
- `lib/features/`: session, wallet, listings, and deal controllers/repositories
- `lib/infrastructure/`: Supabase adapters
- `lib/models/`: typed records retained during the gradual UI migration
- `lib/screens/` and `lib/widgets/`: existing presentation layer

`UserProvider` is a compatibility facade for older screens. New code should depend on the smallest feature controller it needs.

## Verification

```sh
flutter pub get
flutter analyze
flutter test
```

Mobile CI runs these checks for app and Supabase changes.

## Release setup

- Android uses the `com.corridorshare.app` application ID and reads local signing values from `android/key.properties`.
- Copy `android/key.properties.example` locally and point it at a keystore outside Git.
- Configure iOS signing in the organization Apple Developer account.
- Keep Android and iOS as the supported release targets. Generated web and desktop runners remain for tooling compatibility only.
