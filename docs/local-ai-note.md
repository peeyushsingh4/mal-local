# Local AI Note — Architecture & Deterministic Fallback

This document explains the Local AI strategy and fallback implementation for **MAL Local**.

---

## 1. Local AI Architecture Boundary

All AI features in the app are strictly isolated behind the `LocalAiService` abstract interface:

```dart
abstract class LocalAiService {
  Future<ListingSuggestion> suggestListingDetails(String rawInput);
  Future<List<Listing>> searchListings(String query, List<Listing> corpus);
  Future<SafetyFlag> checkListingSafety(Listing draft);
}
```

This interface guarantees that UI components never directly invoke an AI engine, API client, or raw model weight.

---

## 2. On-Device Model Strategy

- **Target Model**: On-device small Gemma variant (e.g. Gemma 2B quantized / Chrome `window.ai` on web or `flutter_gemma` / Mediapipe LLM Inference on mobile).
- **Why Chosen**: Small foot-print, fast local execution without sending user text over the network, zero API key requirement, and privacy by design.

---

## 3. Mandatory Deterministic Fallback Path (`DeterministicAiService`)

A fully real, rule-based fallback path is built into `DeterministicAiService` to guarantee that the app is **100% usable without any AI model loaded or without internet connectivity**.

Reviewers can test this directly by turning off network access and model loading.

### Capability 1: Listing Helper
- **Input**: User phrase (e.g. `"homemade mango pickle, spicy"` or `"math tutor"`).
- **Fallback Logic**:
  - Category Keyword Map matches words against 6 categories (Food, Services, Goods, Lending, Requests, Skills).
  - Title is formatted and capitalized.
  - Template engine generates a clean 2-sentence natural description.
- **Review Step**: Output is filled into the editable description field — **never auto-saved without user review**.

### Capability 2: Search Helper
- **Input**: Natural language search query (e.g. `"something for a kid's birthday"` or `"tiffin"`).
- **Fallback Logic**:
  - Splits input into terms and evaluates semantic/keyword overlap across title, category, description, and neighborhood area.

### Capability 3: Safety Helper
- **Input**: Draft listing before posting.
- **Fallback Logic**:
  - Scans draft using regex heuristics for exact flat/house numbers (`Flat #102`), phone numbers embedded in description text, or sensitive PII (Aadhaar, PAN, Credit Card).
  - Displays a high-priority **Privacy Warning Dialog** with listed issues that the user must acknowledge or edit before posting.
