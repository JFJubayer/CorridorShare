# Friends private beta (web + mobile)

Status: operational guide  
Last reviewed: 2026-08-12

Website and Flutter share the same Supabase contract for a small friends trial. Demo mode is local-only and never holds authoritative KYC or wallet state.

## What works

- Phone OTP sign-in (configured provider or demo code shown in the sign-in UI for mock mode).
- Post trip / post package, corridor matching with adjustable radius (km to meters buffer).
- Deal chat: negotiate, open-box inspection photo, lock escrow, issue delivery OTP, release, refund.
- Meetup pin messages: CS_MEETUP_PIN single-line JSON — one-shot share, OpenStreetMap link, no continuous GPS.
- Optional check-in chips in deal chat as plain chat messages when present.
- Admin portal: NID approve/suspend plus staging wallet credit via admin_credit_wallet.

## What is intentionally out

- No payment gateway (bKash/Nagad) top-up.
- No continuous live GPS tracking.
- Legal pages are honest beta notices, not final Bangladesh counsel copy.
- Automated NID or biometrics; insurance; nationwide optimization engines.

## Staging wallet funding

Only administrator JWTs can call admin_credit_wallet. Use the website Admin portal Credit staging wallet control, or the Flutter admin screen. Members cannot credit themselves. Never put the service-role key in clients.

## Operator checklist

1. Deploy or link the Supabase project with current migrations.
2. Promote trusted friends to profiles.role = admin for KYC and staging credit.
3. Invite friends, have them sign in, submit NID if reviewing, credit wallets for escrow demos.
4. Traveler posts a trip, Matching, send delivery request, deal chat, meetup pin, lock, OTP, release.
5. Wipe or rotate staging data between closed trials as needed.

## Try web specifically

1. Start corridorshare-website (demo mode or staging anon key).
2. Sign in, pick Traveler or Sender mode on Home.
3. Post trip or package; Home lists refresh from repositories.
4. Matching Filter re-runs match_packages_within_corridor using the larger radius in meters.
5. Inbox search filters partner/route; empty states when none.
6. Dismissible friends-beta banner uses localStorage key cs_friends_beta_banner_dismissed.

## Branch note

Friends-beta website pack lives on friends-beta-pack. Do not mix payment-provider work into this trial scope.

## Test phone OTP (friends beta)

Phone SMS provider is not fully production-connected. For closed trials, these numbers use a fixed OTP and do not send SMS:

- `+8801712345678` → OTP `123456`
- `+8801700000001` → OTP `123456`
- `+8801700000002` → OTP `123456`
- `+8801700000003` → OTP `123456`

Any other number still needs a real SMS provider (Twilio/Textlocal/etc.) in the Supabase Auth dashboard.
