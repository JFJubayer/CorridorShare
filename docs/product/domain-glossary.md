# Domain glossary

Status: authoritative  
Last reviewed: 2026-08-12

- **Member:** An authenticated account. A member can act as sender or traveler; these are workflow roles, not security roles.
- **Administrator:** A server-authorized staff member who can review identity status and perform staging wallet credits.
- **Trip:** A traveler's planned route (any Bangladesh LineString), departure time, and available carrying capacity.
- **Package request:** A sender's parcel, pickup/drop-off points, recipient phone (optional name), and proposed reward.
- **Match:** A package whose pickup **and** drop-off both fall within the configured corridor around a trip, optionally filtered by weight ≤ capacity.
- **Deal:** The negotiation and delivery lifecycle joining one trip and one package request.
- **Inspection:** Evidence and affirmation that the traveler viewed the open parcel before locking the deal.
- **Wallet account:** Available and held balances for one member, stored in integer poisha.
- **Hold:** Funds moved from available to held balance when a deal is locked. Lock amount is `coalesce(final_agreed_price_minor, packages.proposed_reward_minor)`.
- **Release:** Held funds paid to the traveler after authorized delivery confirmation.
- **Refund:** Held funds returned to the sender after cancellation.
- **Admin credit:** Administrator-only ledger credit used to fund wallets in staging; not a payment-provider settlement.
- **Demo mode:** A deliberately selected local adapter. Demo identity and money have no production authority.
