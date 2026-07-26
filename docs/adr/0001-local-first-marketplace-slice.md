# ADR 0001: Local-First Flutter Marketplace Slice

## Status
Accepted

## Context
Building a hyperlocal marketplace for one neighborhood (Bandra West) as part of the MAL Lab 1 homework assignment. The application must work local-first, enforce clear architectural boundaries, protect user privacy, and operate offline.

## Decision
1. **Local-first Flutter Architecture**: Built with Flutter (Dart 3) targeting desktop, web, and mobile. All data stays local on-device.
2. **Repository Storage Boundary**: Storage accessed strictly behind `ListingRepository` abstract interface. Implemented via `LocalListingRepository` using `SharedPreferences` + JSON persistence. Can be swapped for `Hive`, `sqflite`, or `drift` without modifying UI widgets.
3. **Product Logic Isolation**: Domain models (`Listing`, `ListingCategory`, `ValidationResult`) encapsulate validation rules and self-expiry tracking logic (`isClosingSoon`).
4. **Local AI Service Boundary**: AI features isolated behind `LocalAiService` interface (`suggestListingDetails`, `searchListings`, `checkListingSafety`). Real deterministic fallback path (`DeterministicAiService`) guarantees zero network API dependency.
5. **Configurable Neighborhood**: Neighborhood name ("Bandra West") is configured in `AppConfig` rather than hardcoded.

## Consequences
- **Positive**:
  - Complete offline functionality; zero cloud server costs or latencies.
  - Clear layer isolation (UI → Service/Repository → Storage/AI).
  - High accessibility compliance using `Semantics` widgets and non-color-only form errors.
- **Negative**:
  - Data does not sync across multiple devices of the same user.
  - Clearing app cache or local storage wipes data unless backed up.

## Future Change Points
- Storage: Swap `LocalListingRepository` with SQLite (`sqflite`/`drift`) or remote REST sync.
- AI: Wire on-device Gemma weights via `flutter_gemma` while keeping fallback active.
- Auth & Sync: Add CRDT sync engine and local device key pair auth above repository layer.
