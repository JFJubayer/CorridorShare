# Data ownership

Status: authoritative  
Last reviewed: 2026-08-01

| Data | Client access | Authoritative mutation |
|---|---|---|
| Profile name/photo | Own profile | Authenticated client under RLS |
| Security role | Read for authorized UI | Server administration only |
| NID status | Read own/admin views | `admin_set_nid_status` |
| Trips and packages | Read authenticated; write own | Owner under RLS |
| Deals | Participant read/create | Narrow deal functions after creation |
| Messages | Participant read/create | Sender under participant RLS |
| Wallet balances | Read own | Server functions only |
| Wallet ledger | Read own | Server functions/provider callbacks only |
| Delivery completion | Read participants | OTP-authorized server function |

Client-side route guards improve user experience but never replace database authorization.

