# Success Metrics — MAL Local (Flutter)

The following testable and demoable metrics evaluate the success of the MAL Local Flutter application during reviewer evaluation:

| Area | Metric | Target / Benchmark | Verified Result |
|---|---|---|:---:|
| **Product** | Main workflow completion time | Create and find a listing in under 3 minutes | ✅ Pass (< 1 min) |
| **Activation** | First useful action | User creates first listing without external guidance | ✅ Pass |
| **Local-first** | Offline persistence | Listings, status changes & AI state survive app relaunch & refresh | ✅ Pass (LocalListingRepository) |
| **Accessibility** | Core flow accessibility | Screen readers navigate feed and form using `Semantics` tags & visible inline errors | ✅ Pass |
| **Security** | Data minimization | Zero exact home addresses, zero secrets, 1-click Data Reset | ✅ Pass (ADR 0002) |
| **Local AI** | Helpful action with fallback | Editable AI suggestions work offline via `DeterministicAiService` | ✅ Pass |
| **Architecture** | Clear boundaries | UI, storage, domain models, and AI service change independently | ✅ Pass |
| **Reliability** | Main flow stability | Zero crashes across feed, search, create, details, reset | ✅ Pass |
| **Project-Specific** | Self-Expiry & Similar Recs | Listings flag "Closing soon in Nd" when < 48h left & suggest category recs | ✅ Pass |
