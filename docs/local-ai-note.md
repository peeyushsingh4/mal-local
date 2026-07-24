# Local AI Documentation

- **Chosen helper**: Listing Helper — assists users in writing listing descriptions by suggesting improved text based on title and category.
- **Architecture boundary**: All AI behavior is behind `LocalAiService` class (`src/ai/LocalAiService.js`). UI code never interacts with the model directly — only through `localAiService.suggestDescription(title, category)`.
- **Deterministic fallback**: `DeterministicFallback` class generates descriptions using category-specific templates. Multiple variants per category for variety. Always available, no model needed. Returns `{ description, confidence: 'template' }`.
- **Local model strategy**: `LocalModelAdapter` class checks for browser-based AI (Chrome's `window.ai` / Gemini Nano). If available, uses it for higher-quality suggestions. Returns `{ description, confidence: 'local-model' }`. Never makes network requests to hosted APIs.
- **Fallback guarantee**: If local model fails or is unavailable, the deterministic fallback is always used. The user always gets a suggestion, regardless of device capabilities.
- **User control**: AI-generated descriptions are always editable. Users can modify, accept, or discard suggestions. `aiGenerated` flag tracks whether the description was AI-assisted.
- **No hosted APIs**: The app does not use OpenAI, Anthropic, Google Cloud AI, or any hosted inference endpoint. All AI runs locally or falls back to templates.
