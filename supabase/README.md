# Shared Supabase backend

This directory owns the database contract used by the website and Flutter clients.

## Rules

- Migrations are append-only after they reach a shared environment.
- Public clients never receive the service-role key.
- Wallet credits require a provider-confirmed service workflow.
- Wallet holds, releases, refunds, KYC decisions, and matching use narrow authorized functions.
- Demo adapters must expose the same feature capabilities without claiming production authority.

## Local verification

```bash
supabase start
supabase db reset
supabase test db
supabase db lint --local --fail-on error
```

The initial migration creates the canonical profiles, wallet, trip, package, deal, and message tables. `tests/security_contract.sql` verifies the highest-risk authorization boundaries.
