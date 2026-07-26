# MAL Local (Flutter)

> A local-first hyperlocal listing board for residents of Bandra West, Mumbai to discover, create, save, contact, and close listings for goods, services, food, lending, requests, and skills — 100% on-device and offline-capable without a backend.

---

## Technical Stack & Choices

| Area | Choice & Description |
|------|----------------------|
| **Platform** | Flutter Mobile, Desktop (macOS) & Web |
| **Language** | Dart 3.12+ |
| **Framework** | Flutter 3.44+ |
| **Local Storage** | `SharedPreferences` + JSON persistence (isolated behind `ListingRepository` boundary) |
| **Local AI** | `LocalAiService` interface with `DeterministicAiService` fallback (zero hosted API keys required) |
| **Design Style** | Blinkit-inspired dense 2-column card grid with Blinkit Yellow (`0xFFF7C413`) & Green (`0xFF0C831F`) theme |

---

## Setup & Running

### Prerequisites
- Flutter SDK 3.19+ / 3.44+ installed

### Commands
```bash
# Get dependencies
flutter pub get

# Run application locally (macOS or Chrome)
flutter run -d macos
# or
flutter run -d chrome

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 3-Minute Demo Script

Follow this script during reviewer evaluation:

1. **Launch App**: Notice persistent top bar showing **`blinkit`** logo badge, **`⚡ 8 MINS`** delivery tag, and neighborhood location **`Bandra West, Mumbai ▾`**.
2. **Browse Feed & Filter**:
   - Scroll through 2-column card grid.
   - Filter by **📤 Offers** vs **📥 Requests**.
   - Tap category chips (e.g. **🍱 Food & Tiffin**, **🔧 Services**).
3. **AI Natural Language Search**: Type *"tiffin"* or *"tutor"* in top search bar to test `LocalAiService.searchListings`.
4. **View Listing Details**: Tap a card (e.g. *"Home-cooked Maharashtrian Tiffin"*).
   - View details, sub-locality (**📍 Pali Hill**), and **"Nearby Similar Listings in Bandra West"** recommendations.
   - Tap **★ Save Listing** or **✉ Mark Contacted** to verify immediate status persistence.
5. **Create Listing with AI & Safety Helpers**:
   - Tap **`+ Post`** FAB button.
   - Type title: *"Homemade Mango Pickle"*
   - Tap **Auto-Suggest Description**. Watch `DeterministicAiService` suggest title/category/description.
   - Select coarse area dropdown: **📍 Pali Hill** (exact street addresses prohibited for privacy).
   - Tap **Post to Bandra West**. (If draft contains house numbers, AI Safety Helper triggers a privacy warning modal!).
6. **Verify Persistence**: Restart or hot-restart the app. Newly posted listing persists across sessions.
7. **Neighborhood Pulse**: Tap chart icon in top hero banner to view activity score and category distribution chart.
8. **Security & Data Reset**: Tap Settings icon → Review Security Posture → Tap **Reset All Local Data** with confirmation modal to wipe storage and restore defaults.

---

## Required Documentation Links

| Document | Description & Path |
|----------|--------------------|
| **Product Slice** | Scope, persona, out-of-scope & original features — [`docs/product-slice.md`](docs/product-slice.md) |
| **Success Metrics** | 9 testable review metrics & benchmarks — [`docs/success-metrics.md`](docs/success-metrics.md) |
| **Accessibility Audit** | `Semantics` tags, inline error text, tap targets & scaling audit — [`docs/accessibility-check.md`](docs/accessibility-check.md) |
| **Security Baseline** | Data minimization, coarse areas & reset flow — [`docs/security-baseline.md`](docs/security-baseline.md) |
| **Local AI Note** | Model strategy & deterministic fallback explanation — [`docs/local-ai-note.md`](docs/local-ai-note.md) |
| **ADR 0001 (Architecture)** | Local-First Architecture Decision Record — [`docs/adr/0001-local-first-marketplace-slice.md`](docs/adr/0001-local-first-marketplace-slice.md) |
| **ADR 0002 (Security)** | Security Skeleton Stance ("Walking Skeleton Has No Skin") — [`docs/adr/0002-security-skeleton-stance.md`](docs/adr/0002-security-skeleton-stance.md) |

---

## Known Gaps

- Out-of-scope by design: Server backend, payments, delivery logistics, chat server, KYC, moderation dashboard.
- On-device Gemma inference uses fallback path (`DeterministicAiService`) when model files are un-downloaded.

---

## License

Built for **MAL Lab 1 Homework**.
