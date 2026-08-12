# MVP scope

Status: authoritative  
Last reviewed: 2026-08-12

CorridorShare connects a sender with a traveler whose planned route passes close to a parcel pickup **and** drop-off point. Both website and mobile are first-class clients of the same Supabase backend.

Routes are **user-defined LineStrings anywhere in Bangladesh**. There is no hard dependency on an N3-only or other fixed corridor catalog.

## Included

- Phone-based user sessions and member profiles.
- Traveler trip creation with a route geometry and capacity (nationwide).
- Sender package requests with pickup/drop-off locations, recipient phone, and reward.
- Corridor matching with bounded near-miss distance; pickup and drop-off must both fall near the trip route; package weight must fit trip capacity when weight is set.
- Participant-only deal chat and inspection evidence (Storage buckets `nid-photos`, `parcel-inspections`).
- Wallet hold, refund, and delivery payout recorded in an immutable ledger.
- Manual NID review by authorized administrators.
- **Admin-only manual wallet credit** (`admin_credit_wallet`) for staging and demos.
- Explicit demo mode for development and presentations.

## Excluded from the current MVP

- Nationwide logistics optimization engines (matching still uses the traveler's own geometry).
- Platform-backed parcel insurance.
- Automated NID or facial recognition / biometric identity.
- **Live payment-provider integration** (no bKash or other provider webhooks in this MVP). Production credits remain deferred until a confirmed provider callback exists (`wallet_credit_from_provider` is service-role only and unused by clients).
- Background live-location / live GPS tracking.
- Desktop Flutter releases.

Legal, payment-provider, privacy, and NID-retention policies require business approval before public launch.
