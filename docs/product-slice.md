# Product Slice Documentation — MAL Local (Flutter)

## 1. Product Summary & Persona

**MAL Local** is a local-first Flutter application for Bandra West, Mumbai. It provides an instant, offline-capable listing board where residents can offer or request goods, services, food, lending, and skills within their immediate neighborhood.

- **Primary Persona**: Riya (a resident of Pali Hill, Bandra West) who wants to share home-cooked tiffins, borrow tools, or find local tutors without creating cloud accounts, sharing exact house addresses, or paying marketplace platform commissions.
- **Problem Statement**: Standard e-commerce and classified apps demand full personal identity, precise location tracking, and constant cloud backend connectivity for simple local exchanges.

---

## 2. Core Scoped Workflow

1. **Browse Feed**: 2-column Blinkit-style grid showing active listings and requests in Bandra West, filterable by Offer vs Request and 6 categories (Food, Services, Goods, Lending, Requests, Skills).
2. **Post Listing / Request**: Easy form with title, category, description, coarse sub-locality dropdown ("Pali Hill", "Carter Road"), contact preference, and AI Description Helper.
3. **Manage Status**: View full listing details, toggle status (**Saved**, **Contacted**, **Closed**), or delete listings. Status changes persist instantly to local storage.

---

## 3. Explicitly Out of Scope

To maintain a clean, local-only architecture without server overhead, the following are explicitly out of scope:
- Payments and escrow
- Delivery logistics & real-time rider tracking
- In-app chat server or push messaging
- KYC / identity verification
- Admin moderation dashboard
- Cloud server infrastructure

---

## 4. One Original Small Feature Choice

**Closing Soon Self-Expiry Tracking & Nearby Recommendations**:
- **Why Chosen**: In a local marketplace, stale or outdated listings clutter the feed. Each listing includes an automatic self-expiry counter (default 7 days). When a listing has under 48 hours remaining, a high-visibility **`Closing in Nd`** badge appears on the card.
- **Bonus Value**: The Details view automatically presents a **"Nearby Similar Listings in Bandra West"** scrollable recommendation bar based on category matching.
