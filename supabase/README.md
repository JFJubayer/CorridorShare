# Shared Supabase backend

This directory owns the database contract used by the website and Flutter clients.

## Rules

- Migrations are append-only after they reach a shared environment.
- Public clients never receive the service-role key.
- Production wallet credits require a provider-confirmed service workflow (`wallet_credit_from_provider`). **Provider webhooks are deferred for MVP.**
- Staging wallets are funded with administrator-only `admin_credit_wallet`.
- Wallet holds, releases, refunds, KYC decisions, and matching use narrow authorized functions.
- Matching requires pickup **and** drop-off near the traveler's route geometry (any BD LineString) and respects trip capacity when package weight is set.
- Demo adapters must expose the same feature capabilities without claiming production authority.

## Local verification

```bash
supabase start
supabase db reset
supabase test db
supabase db lint --local --fail-on error
```

The initial migration creates the canonical profiles, wallet, trip, package, deal, and message tables. Later migrations under `migrations/` are additive. `tests/security_contract.sql` verifies the highest-risk authorization boundaries, matching filters, admin credit, and lock-amount rules.
