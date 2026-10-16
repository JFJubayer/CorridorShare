# Increment 1 Deliverable — Trips, Parcels, and Routing Foundation

Status: Complete & Verified
Date: 2026-10-11

This document records the delivery of Increment 1: core crowd-shipping domain models, data layers, user interface flows, validations, and testing.

---

## 1. Features Delivered

### A. Location & District Architecture
- Standardized Bangladesh 64-districts dataset (`BangladeshDistricts`) under `core/constants/bangladesh_districts.dart`.
- Enforces valid district selection across trips and parcels, preventing typo-based routing mismatches.

### B. Trips Feature (`features/trips/`)
- **Domain**:
  - `Trip` entity (freezed, pure Dart) with fields for route (`fromDistrict`, `fromArea`, `toDistrict`, `toArea`), `departureDate`, `capacityKg`, `noCarryTags`, `note`, and `TripStatus`.
  - `TripStatus` state machine: `open -> full | completed | cancelled` with allowed transition rules.
  - `TripRepository` interface returning `Result<T>`.
  - Use cases: `CreateTrip` (validating capacity, district mismatch, past dates), `GetTrips`, `GetMyTrips`.
- **Data**:
  - `TripDto` (freezed + json_serializable) with domain mapping.
  - `TripDataSource` abstract contract.
  - `InMemoryTripDataSource` with realistic Bangladeshi intercity trips pre-seeded (Dhaka ↔ Chattogram, Sylhet ↔ Dhaka, Dhaka ↔ Rajshahi).
  - `TripRepositoryImpl` translating between DTOs and pure domain models.
- **Presentation**:
  - `trip_providers.dart`: Riverpod providers (`tripsFeedProvider`, `myTripsProvider`, `postTripControllerProvider`).
  - `TripCard`: Material 3 card showing traveller avatar, district route banner, capacity tag, warning no-carry chips, and status badge.
  - `PostTripPage`: Form with district dropdowns (`isExpanded`), departure date picker, capacity validator, no-carry tag toggles, and travel notes.

### C. Parcels Feature (`features/parcels/`)
- **Domain**:
  - `Parcel` entity (freezed, pure Dart) with item details, route, category tags, weight, size, deadline, offered price in BDT, and mandatory `hasProhibitedItemsDeclaration`.
  - `ParcelStatus` state machine: `open -> matched -> inTransit -> delivered | cancelled | disputed`.
  - `ParcelSize` enum (`small`, `medium`, `large`).
  - `ParcelRepository` interface returning `Result<T>`.
  - Use cases: `CreateParcel` (strict validation for weight, positive price, deadline, and mandatory prohibited items declaration), `GetParcels`, `GetMyParcels`.
- **Data**:
  - `ParcelDto` (freezed + json_serializable).
  - `InMemoryParcelDataSource` with seeded realistic parcels (transcripts, Jamdani shawl, electronics).
  - `ParcelRepositoryImpl`.
- **Presentation**:
  - `parcel_providers.dart`: Riverpod providers (`parcelsFeedProvider`, `myParcelsProvider`, `postParcelControllerProvider`).
  - `ParcelCard`: Card displaying item title, sender name, offered price badge (৳ BDT), route, deadline, weight/size tags, and status chip.
  - `PostParcelPage`: Form with category chips, weight & size selector, offered reward, deadline date picker, and mandatory Prohibited Items declaration checkbox.

### D. Navigation & UI Integration
- `HomePage`:
  - Quick-action banner ("Post a Trip" for travellers, "Send a Parcel" for senders).
  - Segmented feed toggle ("Available Travellers" vs "Parcels to Carry").
  - Pull-to-refresh and empty/error states.
- `MyPostsPage`:
  - Two tabs ("Sending" for user's parcels, "Carrying" for user's trips).
  - Floating action button to post new parcel or trip.
- `AppRoutes`:
  - Added `/trips/new` and `/parcels/new` routes.

### E. Localization (en & bn)
- Updated `lib/l10n/app_en.arb` and `lib/l10n/app_bn.arb` with all domain, form, status, and validation strings in English and natural Bangla.

---

## 2. Verification & Testing

- `flutter analyze`: **0 issues** (clean).
- `flutter test`: **55 passed, 0 failed**:
  - `TripStatus` state transitions & terminal states.
  - `CreateTrip` validation (capacity, district mismatch, past dates).
  - `ParcelStatus` state transitions (full lifecycle).
  - `CreateParcel` validation (rejection without prohibited items declaration, price, weight).
  - `PostTripPage` widget tests (rendering, validation, successful submission).
  - `PostParcelPage` widget tests (rendering, declaration blocking, successful submission).
  - `HomePage` widget tests (rendering, segmented tab switching, card feeds).
  - Pre-existing auth and foundation tests.

---

## 3. Next Step (Increment 2)

**Increment 2 — Match & Chat**:
1. Route & date matching engine connecting parcels with suitable trips.
2. Filtering out parcels blocked by the traveller's `noCarryTags`.
3. Offer & Counter-offer flow (`MakeOffer`, `CounterOffer`, `AcceptOffer`).
4. Realtime offer-linked chat thread between sender and traveller.
