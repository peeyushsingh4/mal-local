# MAL Local

> A local-first hyperlocal marketplace web app for residents of Bandra West, Mumbai to discover, create, save, contact, and close listings for goods, services, food, lending, requests, and skills — 100% offline-capable without any backend.

---

## Technical Stack & Choices

| Area | Choice & Description |
|------|----------------------|
| **Platform** | Web (Mobile-responsive SPA designed for desktop and mobile browsers) |
| **Language** | JavaScript (Modern ES Modules) |
| **Framework** | None — Vanilla JS with Vite as dev server and build bundler |
| **Local Storage** | IndexedDB (wrapped behind `ListingRepository` boundary pattern) |
| **Local AI** | `LocalAiService` interface with `DeterministicFallback` (zero hosted API keys required) |
| **Styling** | Vanilla CSS (Swiggy / Blinkit / Zomato aesthetic with Dark and Light mode support) |

---

## Setup & Running

### Prerequisites
- Node.js 18+

### Setup Commands
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

1. **Open the App** (`http://localhost:5173/`): The main feed loads instantly with Bandra West seed listings.
2. **Instant Search & Filter**: Type "tiffin" in the top search bar or click the **🍱 Food** category pill to filter listings in real-time.
3. **View Listing Details**: Click any listing card (e.g., *"Home-cooked Maharashtrian Tiffin"*) to open details page.
4. **Update Status**: Click **★ Save** or **✉ Mark Contacted**. Notice the badge updates immediately.
5. **Create a Listing with AI Helper**: 
   - Click **➕ Create Listing** in the top navigation bar.
   - Enter Title: *"Homemade Mango Pickle"*
   - Select Category: *"Food"*
   - Click **✨ AI Suggest**. Watch the deterministic fallback auto-fill a natural description.
   - Enter Area: *"Pali Hill"*
   - Click **Create Listing**.
6. **Verify Offline Persistence**: Refresh the browser (Ctrl+R / Cmd+R). The newly created listing persists across reloads via IndexedDB.
7. **Neighborhood Pulse**: Click **📊 Pulse** in navigation to view community health score, category distribution bar chart, and AI service status.
8. **Data Reset**: Go to **⚙️ Settings** → Click **🗑 Reset Data** in Danger Zone to delete all IndexedDB data and re-seed defaults.

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
│   │   ├── categories.js   # Category metadata & icons
│   │   └── seedData.js     # 10 realistic Bandra West seed listings
│   ├── storage/
│   │   ├── IndexedDbAdapter.js   # Low-level IndexedDB wrapper
│   │   └── ListingRepository.js  # Swappable Repository storage boundary
│   ├── ai/
│   │   ├── LocalAiService.js     # Public AI Service boundary
│   │   ├── DeterministicFallback.js # Offline template generator
│   │   └── LocalModelAdapter.js  # On-device browser model adapter
│   ├── components/
│   │   ├── Navigation.js         # Header with Blinkit/Swiggy location bar
│   │   ├── ListingFeed.js        # Searchable feed with category pills
│   │   ├── ListingDetail.js      # Listing detail view & status manager
│   │   ├── CreateListingForm.js  # Form with AI description helper & validation
│   │   ├── NeighborhoodPulse.js  # Community activity stats & charts
│   │   ├── Settings.js           # Theme toggle & Data Reset modal
│   │   └── Toast.js              # Accessible notification system
│   └── styles/
│       ├── index.css       # Design tokens (Blinkit/Swiggy palette)
│       └── components.css  # Component & layout styling
└── docs/
    ├── product-slice.md
    ├── success-metrics.md
    ├── accessibility-check.md
    ├── security-baseline.md
    ├── local-ai-note.md
    └── adr/
        └── 0001-local-first-marketplace-slice.md
```

---

## Architectural Boundaries

- **Storage Boundary**: Business logic interacts strictly with `ListingRepository`. The underlying `IndexedDbAdapter` can be replaced with SQLite, CRDTs, or REST API without changing UI code.
- **AI Boundary**: All AI operations are encapsulated inside `LocalAiService`. If browser on-device LLM is absent or user is offline, `DeterministicFallback` generates high-quality text templates. Zero hosted API keys required.
- **Data Privacy**: No precise home addresses are collected; only general area names (e.g., *"Carter Road"*, *"Pali Hill"*).

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

---

## Known Gaps

- Out-of-scope features by design: User authentication, real-time backend sync, payments, delivery tracking, image upload.
- On-device LLM adapter (`window.ai`) requires Chrome Canary flags; fallback handles all standard browsers seamlessly.

---

## License

Built for **MAL Lab 1 Homework**.
