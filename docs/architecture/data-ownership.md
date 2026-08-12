# Data ownership

Status: authoritative  
Last reviewed: 2026-08-12

| Data | Client access | Authoritative mutation |
|---|---|---|
| Profile name/photo | Own profile | Authenticated client under RLS |
| Security role | Read for authorized UI | Server administration only |
| NID status | Read own/admin views | `admin_set_nid_status` |
| NID / inspection objects | Own folder; admin read | Storage policies on `nid-photos` / `parcel-inspections` |
| Trips and packages | Read authenticated; write own | Owner under RLS (terminal package statuses via deal RPCs) |
| Deals | Participant read/create | Narrow deal functions after creation |
| Messages | Participant read/create | Sender under participant RLS |
| Wallet balances | Read own | Server functions only |
| Wallet ledger | Read own | Server functions / future provider callbacks only |
| Staging wallet credit | Admin RPC only | `admin_credit_wallet` |
| Provider wallet credit | None (service_role) | `wallet_credit_from_provider` (deferred until a provider is wired) |
| Delivery completion | Read participants | OTP-authorized server function |

Client-side route guards improve user experience but never replace database authorization.
