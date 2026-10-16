# Increment 2 Deliverable — Matching, Offer Negotiation, and Realtime Chat

Status: Complete & Verified
Date: 2026-10-11

This document records the delivery of Increment 2: corridor route and restriction matching engine, bidirectional offer/counter-offer state machine, parcel status integration, and offer-linked realtime chat stream.

---

## 1. Features Delivered

### A. Matching Engine (`features/matching/`)
- **Domain Logic (`match_check.dart`)**:
  - `isRouteCompatible`: District-level origin and destination corridor equality.
  - `isDateCompatible`: Trip departure date is on or before parcel required delivery deadline.
  - `isCapacityCompatible`: Parcel weight does not exceed traveller's declared remaining capacity in kg.
  - `isBlockedByNoCarry`: Automatic blocking if parcel category tags intersect traveller's restriction list (e.g. `liquid`, `perishable_food`, `fragile`, `electronics`, `hazardous`).
- **Use Cases**:
  - `FindParcelsForTrip`: Queries open parcels and filters matching items according to route, deadline, capacity, and restrictions.
  - `FindTripsForParcel`: Queries open trips matching parcel origin, destination, deadline, and restrictions.
- **Presentation**:
  - `MatchScreen`: Dual-view match finder for both travellers and senders.
  - Displays corridor routes, matching cards, and immediate "Make an Offer" actions.

### B. Offers & Counter-Offers (`features/offers/`)
- **Domain State Machine (`offer_status.dart`)**:
  - States: `pendingTraveller`, `pendingSender`, `accepted`, `rejected`, `cancelled`.
  - Non-terminal alternation: counter-offer switches turn between sender and traveller.
  - Terminal states: `accepted`, `rejected`, `cancelled` strictly disallow subsequent transitions.
- **Entity & Use Cases**:
  - `Offer` entity: immutable freezed model recording price, counterparties, status, timestamps, and `lastCounterBy`.
  - `CreateOffer`: Validates positive BDT price and distinct counterparties.
  - `CounterOffer`: Validates counter price and alternates pending responder.
  - `AcceptOffer`: Transitions offer to `accepted` and **automatically updates the underlying parcel to `matched`** (`ParcelStatus.matched`).
  - `RejectOffer`: Closes negotiation as declined.
  - `GetMyOffers`: Retrieves active and resolved negotiations.
- **Data Layer**:
  - `OfferDto` (freezed, JSON serializable).
  - `OfferDataSource` contract and `InMemoryOfferDataSource` pre-seeded with active negotiations.
  - `OfferRepositoryImpl` with `Result<T>` error handling.
- **Presentation**:
  - `MakeOfferSheet`: Modal bottom sheet featuring proposal price input and a **prominent warning banner detailing the traveller's no-carry restrictions** before submission.
  - Dynamic action bar in chat with Accept, Counter, and Decline buttons.

### C. Realtime Offer-Linked Chat (`features/chats/`)
- **Domain**:
  - `ChatMessage` and `ChatConversation` entities.
  - `SendMessage`: Enforces non-empty message validation and attaches sender metadata.
  - `GetMessagesStream`: Exposes realtime `Stream<List<ChatMessage>>` tied to offer ID.
  - `GetConversations`: Aggregates active chats with latest message snippets, timestamps, and counterpart information.
- **Data Layer**:
  - `ChatMessageDto` with serialization and domain mapping.
  - `InMemoryChatDataSource`: Stream-controller based broadcast pipeline emitting initial seed history and live message updates.
  - `ChatRepositoryImpl`.
- **Presentation**:
  - `ChatConversationPage`:
    - Responsive message stream with sender-differentiated chat bubbles.
    - Persistent offer status & negotiation header.
    - Counter-offer dialog with price validator.
    - Message composer with send button and auto-scrolling.
  - `ChatsPage`: Active conversations list with counterpart avatars, route subtitle, and latest message previews.

### D. Routing & Localization
- Added `/match` (`AppRoutes.match`) and `/chats/:id` (`AppRoutes.chatDetail`) to `go_router`.
- ARB files updated with complete English (`app_en.arb`) and natural Bangla (`app_bn.arb`) strings for negotiation, counter-offers, chat, and match warnings.

---

## 2. Verification & Testing

- `flutter analyze`: **0 issues** across all packages.
- `flutter test`: **85 passed, 0 failed**:
  - Matching logic unit tests (`isRouteCompatible`, `isDateCompatible`, `isCapacityCompatible`, `isBlockedByNoCarry`).
  - Matching use case integration tests (`FindParcelsForTrip`, `FindTripsForParcel`).
  - `OfferStatus` state machine unit tests (transitions, terminal guards).
  - `Offer` use case tests (`CreateOffer`, `CounterOffer`, `AcceptOffer` parcel status synchronization, `RejectOffer`, `GetMyOffers`).
  - `Chat` use case tests (`SendMessage` validation, stream emission order, conversation aggregation).
  - `MatchScreen` widget tests (compatible listings, opening `MakeOfferSheet`, no-carry restriction warnings).
  - `ChatConversationPage` widget tests (message stream rendering, sending messages, accepting offers).
  - Complete regression test suite for Foundation and Increment 1.

---

## 3. Ready for Increment 3

**Increment 3 — Verification & Delivery Tracking**:
1. Pickup verification flow: Sender handover with parcel photo upload & condition check.
2. Two-Factor Delivery Verification: 4-digit numeric handover code generated for recipient and entered by traveller upon delivery.
3. Parcel status progression: `matched -> inTransit -> delivered`.
4. Dispute reporting flow for damaged, missing, or mismatched items.
