# Accessibility Audit

- **Labels**: All interactive elements have aria-labels or visible text labels. Buttons use descriptive text ("Create listing" not just "Submit").
- **Screen reader support**: Listing cards use semantic HTML (`<article>`, heading, status). Feed has aria-label. Empty states are announced.
- **Form errors**: Visible error messages with icon AND text (not color-only). Errors are associated with inputs via `aria-describedby`. Error count announced to screen reader via `aria-live`.
- **Tap targets**: All interactive elements are minimum 48x48px. Adequate spacing between targets.
- **Text scaling**: App is readable at 200% zoom. Uses relative units (`rem`/`em`) where appropriate.
- **Focus management**: Visible focus indicators (2px solid outline). Logical tab order. Focus moves to new content on navigation. Skip-to-content link.
- **Color contrast**: Text meets WCAG AA contrast ratio (4.5:1 for body text). Status indicators use icon + text, not just color.
- **Keyboard navigation**: All features accessible via keyboard. Escape closes modals. Enter/Space activate buttons.
- **Reduced motion**: Animations respect `prefers-reduced-motion` media query.
