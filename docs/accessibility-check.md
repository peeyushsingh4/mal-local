# Accessibility Audit & Check — MAL Local (Flutter)

This document details the visual, screen-reader, and keyboard accessibility implementations in **MAL Local**.

---

## 1. Explicit `Semantics` Annotations

- **Navigation & Header Bar**: Wrapped in `Semantics(label: 'Main header bar showing delivery time 8 minutes and current neighborhood Bandra West, Mumbai', header: true)`.
- **Listing Cards**: Each card in the 2-column grid is wrapped in a single composed `Semantics` node:
  ```dart
  Semantics(
    label: 'Listing: Title. Category: Food. Type: Offer. Area: Pali Hill. Status: Active. Closing soon in 2 days',
    button: true,
    child: ...
  )
  ```
- **Category Chips**: Filter pills use `Semantics(label: 'Filter by category Food', button: true, selected: isSelected)`.
- **FAB (+ Post)**: Prominent action button annotated with `Semantics(label: 'Create new listing or request in Bandra West', button: true)`.

---

## 2. Visible Inline Form Errors (Non-Color Only)

- Form errors in `CreateScreen` display visual red borders **AND** explicit inline text below the field using a `Row` containing an error icon and text:
  ```dart
  Row(
    children: [
      Icon(Icons.error_outline, size: 16, color: BlinkitTheme.zomatoRed),
      SizedBox(width: 4),
      Text(msg, style: TextStyle(color: BlinkitTheme.zomatoRed, fontWeight: FontWeight.bold)),
    ],
  )
  ```
- Color is never used as the sole indicator of validation state.

---

## 3. Tap Target Sizes & System Text Scaling

- **48x48 Minimum Tap Targets**: All buttons, chips, FAB, and interactive form fields enforce `minimumSize: const Size(48, 48)` or equivalent padding to comply with WCAG 2.1 AA.
- **System Text Scaler Awareness**: All text widgets use `MediaQuery.textScalerOf(context)` or flexible scroll views to prevent text clipping when users increase device font scaling settings up to 200%.

---

## 4. Verification Pass

- Tested via Flutter `showSemanticsDebugger: false` and screen reader accessibility tools.
- Verified keyboard tab focus navigation on desktop and web builds.
