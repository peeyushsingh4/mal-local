# MAL Local

> A local-first hyperlocal marketplace web app for residents of Bandra West, Mumbai to discover, create, save, contact, and close listings for goods, services, food, lending, requests, and skills — 100% offline-capable without any backend.

---

## 🎨 Blinkit App UI/UX Redesign

- **Blinkit Header & Location Bar**: Features the iconic **`blinkit`** logo badge with dynamic **`⚡ 8 MINS`** delivery pill and **`📍 Bandra West, Mumbai ▾`** location picker.
- **Hero Express Banner & Real-time Search**: High-impact banner + instant search bar (`🔍 Search tiffins, tutors, plumbers, books, electronics in Bandra West...`).
- **Story Category Scroll Grid**: Category pills with custom SVG icons (`🍱 Food`, `🔧 Services`, `📦 Goods`, `🤝 Lending`, `🙏 Requests`, `🎓 Skills`).
- **Blinkit Product Cards**: Cards with high-visibility **`ADD +`** green action buttons, time tags, category tints, and quick contact action buttons.

---

## 🔒 Security ADR 0002: "The Walking Skeleton Has No Skin"

Implemented formal Security ADR ([`docs/adr/0002-security-skeleton-stance.md`](docs/adr/0002-security-skeleton-stance.md)) covering the 5 Skeleton-Stage Decisions from the MAL Lab 01 Security ADR specification:

1. **Where do your secrets live?** Zero hardcoded API keys, tokens, or private secrets inside binary/bundle. `LocalAiService` uses browser-native LLM (`window.ai`) or `DeterministicFallback`.
2. **Where is the client/server trust boundary?** Client treated as hostile; HTML sanitization + domain model validation enforced on-device. Server re-validation mandated for backend sync.
3. **Is data-at-rest encrypted — and where's the key?** Browser IndexedDB origin-isolated by SOP. Data minimized to neighborhood areas ("Pali Hill", "Carter Road"). 1-click **Data Reset** in Settings.
4. **What is your certificate-pinning stance?** Explicitly deferred for offline local slice; stance recorded for future HTTPS endpoints.
5. **What telemetry leaves the device?** **Zero telemetry / Zero PII exfiltration**.

---

## Technical Stack & Choices

| Area | Choice & Description |
|------|----------------------|
| **Platform** | Web (Mobile-responsive SPA designed for desktop and mobile browsers) |
| **Language** | JavaScript (Modern ES Modules) |
| **Framework** | None — Vanilla JS with Vite as dev server and build bundler |
| **Local Storage** | IndexedDB (wrapped behind `ListingRepository` boundary pattern) |
| **Local AI** | `LocalAiService` interface with `DeterministicFallback` (zero hosted API keys required) |
| **Styling** | Vanilla CSS (Blinkit Yellow `#F7C413`, Blinkit Green `#0C831F` & Swiggy/Zomato palette) |

---

## Setup & Running

### Prerequisites
- Node.js 18+

### Commands
```bash
# Install dependencies
npm install

# Start local development server
npm run dev

# Build production bundle
npm run build

# Preview production build
npm run preview
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

---

## 3-Minute Demo Script

Follow this script during reviewer evaluation:

1. **Open the App** (`http://localhost:5173/`): Notice the **`blinkit`** logo, **`⚡ 8 MINS`** delivery badge, and location picker (`Bandra West, Mumbai`).
2. **Instant Search & Filter**: Type "tiffin" in the search input or click **🍱 Food & Tiffin** category pill.
3. **View Listing Details**: Click any card (e.g., *"Home-cooked Maharashtrian Tiffin Packs"*) to open details page.
4. **Update Status**: Click **★ Save** or **✉ Mark Contacted**. Notice the badge updates immediately.
5. **Create a Listing with AI Helper**: 
   - Click **➕ Create Listing** in the top navigation bar.
   - Enter Title: *"Homemade Mango Pickle"*
   - Select Category: *"Food & Tiffin"*
   - Click **✨ AI Description Helper**. Watch `DeterministicFallback` auto-fill a description.
   - Enter Area: *"Pali Hill"*
   - Click **Create Listing**.
6. **Verify Offline Persistence**: Refresh the browser (Ctrl+R / Cmd+R). The newly created listing persists across reloads via IndexedDB.
7. **Neighborhood Pulse**: Click **📊 Pulse** in navigation to view community health score, category distribution bar chart, and AI service status.
8. **Security & Data Reset**: Go to **⚙️ Settings** → Review **Security Posture** → Click **🗑 Reset Data** in Danger Zone to delete all IndexedDB storage and re-seed defaults.

---

## Project Structure & Architecture

```
mal-local/
├── index.html              # Accessible HTML5 SPA shell
├── netlify.toml            # Netlify deployment configuration
├── package.json            # Vite project configuration
├── vite.config.js          # Minimal Vite config
├── src/
│   ├── main.js             # Entry point, router wiring & initialization
│   ├── router/Router.js    # SPA Hash router with param matching
│   ├── models/
│   │   ├── Listing.js      # Listing domain model + validation & sanitization
│   │   └── Neighborhood.js # Neighborhood value object
│   ├── data/
│   │   ├── categories.js   # Category metadata & colors
│   │   └── seedData.js     # 10 realistic Bandra West seed listings
│   ├── storage/
│   │   ├── IndexedDbAdapter.js   # Low-level IndexedDB wrapper
│   │   └── ListingRepository.js  # Swappable Repository storage boundary
│   ├── ai/
│   │   ├── LocalAiService.js     # Public AI Service boundary
│   │   ├── DeterministicFallback.js # Offline template generator
│   │   └── LocalModelAdapter.js  # On-device browser model adapter
│   ├── components/
│   │   ├── icons.js              # SVG icons helper (Blinkit icons)
│   │   ├── Navigation.js         # Header with Blinkit logo & 8 MINS delivery pill
│   │   ├── ListingFeed.js        # Searchable feed with category pills & Blinkit cards
│   │   ├── ListingDetail.js      # Listing detail view & status manager
│   │   ├── CreateListingForm.js  # Form with AI description helper & validation
│   │   ├── NeighborhoodPulse.js  # Community activity stats & distribution chart
│   │   ├── Settings.js           # Theme toggle, Security posture & Data Reset modal
│   │   └── Toast.js              # Accessible notification system
│   └── styles/
│       ├── index.css       # Design tokens (Blinkit Yellow & Green palette)
│       └── components.css  # Component & Blinkit card styling
└── docs/
    ├── product-slice.md
    ├── success-metrics.md
    ├── accessibility-check.md
    ├── security-baseline.md
    ├── local-ai-note.md
    └── adr/
        ├── 0001-local-first-marketplace-slice.md
        └── 0002-security-skeleton-stance.md
```

---

## Architectural Boundaries

- **Storage Boundary**: Business logic interacts strictly with `ListingRepository`. The underlying `IndexedDbAdapter` can be replaced with SQLite, CRDTs, or REST API without changing UI code.
- **AI Boundary**: All AI operations are encapsulated inside `LocalAiService`. If browser on-device LLM is absent or user is offline, `DeterministicFallback` generates high-quality text templates. Zero hosted API keys required.
- **Security Boundary**: Follows **ADR 0002** ("The Walking Skeleton Has No Skin"). No secrets shipped in bundle, client treated as untrusted, data minimized, zero telemetry exfiltration.

---

## Required Evidence Documentation Links

| Document | Description & Path |
|----------|--------------------|
| **Product Slice** | Persona, problem statement, workflow & scope — [`docs/product-slice.md`](docs/product-slice.md) |
| **Success Metrics** | 9 testable review metrics — [`docs/success-metrics.md`](docs/success-metrics.md) |
| **Accessibility Audit** | WCAG 2.1 AA audit & implementation details — [`docs/accessibility-check.md`](docs/accessibility-check.md) |
| **Security Baseline** | Secrets, data minimization & reset audit — [`docs/security-baseline.md`](docs/security-baseline.md) |
| **Local AI Note** | AI architecture boundary & fallback strategy — [`docs/local-ai-note.md`](docs/local-ai-note.md) |
| **ADR 0001** | Local-First Architecture Decision Record — [`docs/adr/0001-local-first-marketplace-slice.md`](docs/adr/0001-local-first-marketplace-slice.md) |
| **ADR 0002 (Security)** | Security Skeleton Stance ("Walking Skeleton Has No Skin") — [`docs/adr/0002-security-skeleton-stance.md`](docs/adr/0002-security-skeleton-stance.md) |

---

## Known Gaps

- Out-of-scope features by design: User authentication, real-time backend sync, payments, delivery tracking, image upload.
- On-device LLM adapter (`window.ai`) requires Chrome Canary flags; fallback handles all standard browsers seamlessly.

---

## License

Built for **MAL Lab 1 Homework**.
