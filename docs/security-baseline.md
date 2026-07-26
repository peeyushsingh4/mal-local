# Security Baseline & Security ADR Implementation

This document outlines the security posture of **MAL Local** based on the **MAL Lab 01 Security ADR: "The Walking Skeleton Has No Skin"** ([`docs/adr/0002-security-skeleton-stance.md`](adr/0002-security-skeleton-stance.md)).

## Summary of the 5 Skeleton-Stage Decisions

1. **Secrets Management**: No API keys, secret tokens, or private service credentials inside the app bundle. AI features run locally or via deterministic fallback ([`src/ai/LocalAiService.js`](../src/ai/LocalAiService.js)).
2. **Client/Server Trust Boundary**: Inputs validated and sanitized in [`Listing.js`](../src/models/Listing.js). The client is treated as untrusted; server-side re-validation will be enforced when backend sync is introduced.
3. **Data-at-Rest & Key Isolation**: Stored locally in IndexedDB protected by browser Same-Origin Policy (SOP). Exact house/flat numbers and live GPS tracking are rejected in favor of neighborhood area names ("Pali Hill", "Carter Road"). Users can instantly wipe local data in Settings.
4. **Certificate Pinning**: Deferred for offline slice as zero network requests leave the device. Stance documented for future HTTPS API endpoints.
5. **Telemetry & Privacy Allowlist**: Zero telemetry exfiltration. No third-party trackers, crash reporters, or analytics scripts.

## Threat Model & Controls

- **XSS Mitigation**: HTML tags stripped automatically from user input via domain model sanitization.
- **Data Minimization**: No personal identity, exact home address, or payment details stored on-device.
- **Data Reset**: Instant wipe capability in Settings clears IndexedDB completely.
- **Reference**: See [`docs/adr/0002-security-skeleton-stance.md`](adr/0002-security-skeleton-stance.md) for full decision records.
