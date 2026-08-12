# Architecture overview

Status: authoritative  
Last reviewed: 2026-08-12

CorridorShare uses two clients and one shared backend contract.

```text
Next.js web client ─┐
                    ├─ feature actions/controllers ─ repositories ─ Supabase
Flutter client ─────┘                                      └─────── demo adapters
```

## Boundary rules

- Routes and screens compose features and render state.
- Feature actions/controllers own workflow meaning, validation, authorization expectations, and state transitions.
- Repositories expose explicit domain operations and return structured results.
- Infrastructure adapters own Supabase, LocalStorage, networking, and provider SDK mechanics.
- Sensitive decisions are enforced again by RLS or narrow server-side functions.
- The database schema under `supabase/migrations/` is the canonical cross-client contract.
- Trip matching is geometry-based for any Bangladesh route LineString; escrow lock amounts follow the agreed package reward rule documented on `lock_deal_with_inspection`.
- Demo and live adapters implement equivalent capabilities; UI code does not inspect the storage provider.

Avoid generic services that combine unrelated features. Add `data/domain/presentation` subfolders only after a feature has enough code to justify them.

