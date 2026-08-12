# CorridorShare

CorridorShare is a peer-to-peer crowd-shipping platform connecting parcel senders with travelers already moving along the same highway corridor in Bangladesh.

[![Website CI](https://github.com/JFJubayer/CorridorShare/actions/workflows/website-ci.yml/badge.svg)](https://github.com/JFJubayer/CorridorShare/actions/workflows/website-ci.yml)
[![Mobile CI](https://github.com/JFJubayer/CorridorShare/actions/workflows/mobile-ci.yml/badge.svg)](https://github.com/JFJubayer/CorridorShare/actions/workflows/mobile-ci.yml)
[Live website](https://corridorshare-tan.vercel.app)

## Repository layout

```text
corridorshare-website/  Next.js and React web client
corridorshare-app/      Flutter mobile client
supabase/               Shared database migrations, policies, tests, and functions
docs/                   Product, architecture, decisions, and operations
```

The database is the shared contract between both clients. Product-sensitive operations such as wallet movements, escrow release, identity approval, and administrative actions must run through authorized server-side functions. MVP matching works nationwide on traveler-defined Bangladesh routes; live payment-provider credits are deferred — use admin staging credit in non-production environments.

## Quick start

### Website

```bash
cd corridorshare-website
cp .env.example .env.local
npm ci
npm run dev
```

Set `NEXT_PUBLIC_DATA_MODE=demo` for a local browser-only demo. Supabase is the default data mode and requires the public project URL and anonymous key.

### Flutter

```bash
cd corridorshare-app
flutter pub get
flutter run --dart-define=DATA_MODE=demo
```

Use the Flutter version documented by the mobile project. Android and iOS are the supported release targets.

### Shared database

```bash
supabase start
supabase db reset
supabase test db
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/operations/local-development.md](docs/operations/local-development.md) for the complete workflow.
