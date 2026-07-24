# ADR 0001: Local-First Marketplace Slice

## Status
Accepted

## Context
Building a hyperlocal marketplace for one neighborhood (MAL Lab 1 homework context), which needs to work offline, demonstrate clear architecture boundaries, and respect user privacy.

## Decision
1. **Local-first storage with IndexedDB**: Chose IndexedDB for persistent, structured, offline storage. Data never leaves the browser. Wrapped behind ListingRepository interface for swappability.
2. **Repository pattern for storage boundary**: ListingRepository provides clean CRUD interface. IndexedDbAdapter handles the actual persistence. Can be swapped for SQLite, remote API, or CRDTs without changing business logic.
3. **Product logic isolation**: Domain models (Listing, Neighborhood) contain validation and business rules. UI components consume models via repository — no direct storage access.
4. **AI service boundary**: LocalAiService isolates all AI behavior. Two implementations behind it: LocalModelAdapter (browser AI) and DeterministicFallback (templates). UI only knows about LocalAiService.suggestDescription().
5. **Hash-based SPA routing**: Simple client-side router using URL hash. No server required. Enables deep-linking to listing details.
6. **Vanilla JS with Vite**: Minimal dependencies. Only Vite as dev dependency. No framework lock-in. Demonstrates architecture patterns without framework magic.

## Consequences
- **Positive**: 
  - Complete offline capabilities and privacy by default.
  - Clear architectural boundaries allow easy swaps of underlying technologies.
  - Zero cloud infrastructure costs.
- **Negative**:
  - Data doesn't sync across user devices.
  - Users can lose data if they clear browser storage.

## Future Change Points
- Storage: Replace IndexedDbAdapter with a remote API adapter for sync
- AI: Replace LocalModelAdapter with a more capable local model (WebLLM, transformers.js)
- Sync: Add CRDT or operational transform layer above ListingRepository
- Auth: Add user identity above the product logic layer
- Platform: Port UI components to React Native, Flutter, or native — domain models and repository interface stay the same
