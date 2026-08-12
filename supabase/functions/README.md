# Supabase Edge Functions

Place provider-confirmed payment callbacks and other service-role workflows here when a payment provider is selected.

**MVP status:** no payment-provider (e.g. bKash) webhooks are shipped. Staging wallet funding uses the database RPC `admin_credit_wallet` (administrator JWT only). Client applications must never credit wallets or approve identity checks directly.
