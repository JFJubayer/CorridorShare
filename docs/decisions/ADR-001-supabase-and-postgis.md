# ADR-001: Supabase and PostGIS as the shared backend

Status: accepted  
Date: 2026-08-01

## Decision

Use Supabase Auth, PostgreSQL, PostGIS, Storage, and Realtime as the shared backend for the Next.js and Flutter clients. Keep migrations at the repository root. Use explicit demo adapters for local presentations.

## Consequences

- Both clients must follow one versioned schema contract.
- Spatial matching belongs in an ownership-checked database function over arbitrary trip LineStrings (nationwide Bangladesh), not a fixed corridor catalog.
- RLS and function authorization are required even when the UI has guards.
- Production payment credits require a trusted provider callback using service-role authority (`wallet_credit_from_provider`). That integration is **deferred** for the current MVP.
- Staging funding uses administrator-only `admin_credit_wallet` (ledger write). Ordinary members cannot credit wallets.
- LocalStorage and in-memory data cannot silently replace production services.

