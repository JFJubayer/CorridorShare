# Local development

Status: authoritative  
Last reviewed: 2026-08-01

## Requirements

- Node.js 22 and npm.
- Flutter version pinned by the mobile project and a compatible Dart 3 SDK.
- Docker and Supabase CLI for database work.

## Data modes

Supabase is the default. It requires the project URL and anonymous key in each client. Demo mode must be selected explicitly and stores no authoritative identity, wallet, or KYC state.

Use `.env.example` as the website configuration template. Never put service-role credentials in a public client variable.

## Database changes

Create a new timestamped migration for every change. Never modify a migration already applied to a shared environment. Run database security tests against a disposable local database before deploying.

## Release checks

Run website lint, tests, production build, and production dependency audit. Run Flutter analyze and tests. Mobile release signing and payment-provider secrets stay outside Git and are supplied by the release environment.

