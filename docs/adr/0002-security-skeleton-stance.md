# ADR 0002: Security Skeleton Stance ("The Walking Skeleton Has No Skin")

## Status
Accepted (Lab 01 Security ADR Baseline)

## Date
11 Jul 2026 / Updated July 2026

## Context
Building the initial local-first slice for **MAL Local** (hyperlocal marketplace for Bandra West, Mumbai). We must establish a clear security posture covering device secrets, client-server trust boundaries, data-at-rest protection, certificate pinning, and telemetry before scaling the codebase.

---

## §2 The Five Skeleton-Stage Decisions

### 01. Where do your secrets live?
- **Decision**: **ZERO SECRETS ON DEVICE / IN BINARY**.
- **Stance**: No API keys, secret tokens, or private endpoints are hardcoded in source code, bundled `.env`, or Vite configs.
- **Implementation**: The app uses `LocalAiService` with browser-native models (`window.ai`) or `DeterministicFallback`. No third-party LLM API keys (OpenAI, Gemini, Anthropic) are required or embedded.
- **Cost to Reverse**: Permanent — Shipped secrets must be treated as immediately leaked.

### 02. Where is the client / server trust boundary?
- **Decision**: **CLIENT IS TREATED AS HOSTILE; INPUTS SANITIZED AT BOUNDARY**.
- **Stance**: All user inputs (title, area, description) pass through strict domain model validation (`Listing.js`) and HTML sanitization before storage.
- **Architectural Boundary**: For this offline-first slice, local validation enforces privacy & data minimization. When a backend/sync server is attached, server-side re-validation, authorization, and price/status enforcement will be mandatory.
- **Cost to Reverse**: High — Moving trust boundaries later requires API redesigns.

### 03. Is data-at-rest encrypted — and where's the key?
- **Decision**: **ORIGIN-ISOLATED LOCAL STORAGE WITH DATA MINIMIZATION AND RESET**.
- **Stance**: Local data resides in browser IndexedDB, protected by browser same-origin policy (SOP). Sensitive location data is minimized to neighborhood areas (e.g. "Pali Hill", "Carter Road"), never exact house numbers or live GPS coordinates.
- **Key Stance**: User retains 100% control with an instant **Data Reset** function in Settings to purge all IndexedDB storage. Future native builds (Flutter/Android/iOS) will use SQLCipher with keys in KeyChain/KeyStore.
- **Cost to Reverse**: High — Retrofitting encryption on live DB requires data migration.

### 04. What is your certificate-pinning stance?
- **Decision**: **DEFERRED FOR LOCAL-FIRST SLICE; DOCUMENTED FOR NETWORK SYNC**.
- **Stance**: For this offline-first local slice, zero outgoing network calls are made. HTTPS certificate pinning is explicitly deferred until a remote sync API server is introduced.
- **Cost to Reverse**: Cheap — Deferred intentionally with documented stance.

### 05. What telemetry leaves the device?
- **Decision**: **ZERO TELEMETRY / ZERO PII EXFILTRATION**.
- **Stance**: Strict allowlist: **Nothing leaves the device**. No third-party analytics (Google Analytics, Mixpanel), crash reporters with PII, or hidden network pings exist in the project.
- **Cost to Reverse**: Medium — Unfiltered PII in logs/vendor backups cannot be undone.

---

## §3 Decision Summary
- **No long-lived secrets inside the client app.**
- **No hosted AI API dependency; offline deterministic fallback guarantees reliability.**
- **Zero telemetry exfiltration & total local control over data reset.**

## §4 Consequences We Accept
- Local storage relies on browser same-origin sandboxing. Clearing browser storage deletes local listings unless exported as JSON.
- Certificate pinning is deferred until network sync infrastructure is deployed.
