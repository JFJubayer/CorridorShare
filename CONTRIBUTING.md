# Contributing

## Before changing code

1. Read `docs/product/mvp-scope.md` and `docs/architecture/overview.md`.
2. Keep routes and screens focused on presentation and orchestration.
3. Put provider mechanics in repositories or infrastructure adapters.
4. Put authorization, state transitions, and failure classification in feature actions or server functions.
5. Add or update tests for observable behavior.

## Verification

Website:

```bash
cd corridorshare-website
npm ci
npm run lint
npm test
npm run build
npm audit --omit=dev
```

Mobile:

```bash
cd corridorshare-app
flutter pub get
flutter analyze
flutter test
```

Database:

```bash
supabase start
supabase db reset
supabase test db
```

Never commit environment files, service-role keys, mobile signing keys, NID images, payment credentials, or production data.

