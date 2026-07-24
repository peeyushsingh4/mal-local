/**
 * Adapter for browser-based local AI models.
 * Currently a stub — can be extended to use WebLLM, transformers.js,
 * or Chrome's built-in Gemini Nano via window.ai.
 * 
 * The key contract: this adapter NEVER makes network requests to hosted APIs.
 * It only uses models that run locally in the browser.
 */
export class LocalModelAdapter {
  constructor() {
    this._available = false;
    this._model = null;
  }

  /**
   * Attempt to initialize a local model.
   * Returns true if a local model is available, false otherwise.
   */
  async initialize() {
    // Check for window.ai (Chrome built-in AI)
    // Check for any pre-loaded WebLLM model
    // If neither available, return false
    try {
      if (typeof window !== 'undefined' && window.ai && window.ai.languageModel) {
        this._model = await window.ai.languageModel.create();
        this._available = true;
        return true;
      }
    } catch (e) {
      console.log('[LocalModelAdapter] No local model available, using fallback.', e.message);
    }
    this._available = false;
    return false;
  }

  async suggestDescription(title, category) {
    if (!this._available || !this._model) return null;
    try {
      const prompt = `You are a helpful assistant for a neighborhood marketplace in Bandra West, Mumbai. Generate a friendly, concise listing description (2-3 sentences) for:\n\nTitle: ${title}\nCategory: ${category}\n\nDescription:`;
      const result = await this._model.prompt(prompt);
      return { description: result.trim(), confidence: 'local-model' };
    } catch (e) {
      console.warn('[LocalModelAdapter] Model inference failed:', e.message);
      return null;
    }
  }

  isAvailable() {
    return this._available;
  }

  getModelInfo() {
    return {
      available: this._available,
      type: this._available ? 'browser-local' : 'none',
      name: this._available ? 'Chrome Built-in AI' : 'N/A'
    };
  }
}
