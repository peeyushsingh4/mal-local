# Security Documentation

- **Secrets management**: No API keys, tokens, or secrets in the codebase. No `.env` file committed. AI features use local model or deterministic fallback — no hosted API calls.
- **Location privacy**: No exact home addresses stored. Listings use area names ("Pali Hill", "Carter Road") not street addresses. No GPS/geolocation API used. No precise coordinates stored.
- **Input validation**: All listing fields validated before saving. HTML tags stripped from inputs. Title: 3-100 chars. Description: 10-1000 chars. Category: from predefined list only. Address-like patterns flagged.
- **Data minimization**: Only essential listing data stored. No personal data beyond contact preference. No tracking, analytics, or cookies. No third-party scripts with data access.
- **Data reset**: Users can delete all local data from Settings. Clear confirmation before destructive action. Reset removes all IndexedDB data. No residual data after reset.
- **Storage security**: Data stored in IndexedDB (browser sandboxed). No data sent to external servers. Same-origin policy applies. Users can inspect/delete via browser DevTools.
- **Threat model**: Local-only app with minimal attack surface. Main risks: XSS via listing content (mitigated by HTML stripping), local data exposure (mitigated by data minimization), dependency vulnerabilities (mitigated by minimal dependencies — only Vite as dev dependency).
