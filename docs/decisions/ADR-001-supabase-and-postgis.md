# ADR-001: Supabase and PostGIS as the shared backend

Status: accepted  
Date: 2026-08-01

## Decision

Use Supabase Auth, PostgreSQL, PostGIS, Storage, and Realtime as the shared backend for the Next.js and Flutter clients. Keep migrations at the repository root. Use explicit demo adapters for local presentations.

## Consequences

- Both clients must follow one versioned schema contract.
- Spatial matching belongs in an ownership-checked database function.
- RLS and function authorization are required even when the UI has guards.
- Payment credits require a trusted provider callback using service-role authority.
- LocalStorage and in-memory data cannot silently replace production services.

