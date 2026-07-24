import { DeterministicFallback } from './DeterministicFallback.js';
import { LocalModelAdapter } from './LocalModelAdapter.js';

/**
 * LocalAiService — The AI boundary for MAL Local.
 * 
 * This service provides AI-powered features with a guaranteed fallback.
 * It NEVER requires network access or hosted API keys.
 * 
 * Architecture:
 * 1. Try local model (browser-based AI) if available
 * 2. Fall back to deterministic template-based generation
 * 
 * The fallback ALWAYS works, ensuring the app is fully functional
 * even without any AI model loaded.
 */
export class LocalAiService {
  constructor() {
    this.localModel = new LocalModelAdapter();
    this.fallback = new DeterministicFallback();
    this._initialized = false;
    this._useModel = false;
  }

  async initialize() {
    try {
      this._useModel = await this.localModel.initialize();
    } catch (e) {
      this._useModel = false;
    }
    this._initialized = true;
    console.log(`[LocalAiService] Initialized. Using ${this._useModel ? 'local model' : 'deterministic fallback'}.`);
  }

  async suggestDescription(title, category) {
    if (!this._initialized) await this.initialize();
    
    // Try local model first
    if (this._useModel) {
      const modelResult = await this.localModel.suggestDescription(title, category);
      if (modelResult) return modelResult;
    }
    
    // Fallback — always works
    return this.fallback.suggestDescription(title, category);
  }

  suggestTags(title, category) {
    return this.fallback.suggestTags(title, category);
  }

  getStatus() {
    return {
      initialized: this._initialized,
      modelAvailable: this._useModel,
      modelInfo: this.localModel.getModelInfo(),
      fallbackAvailable: true
    };
  }

  isAvailable() {
    return true; // Always available due to fallback
  }
}

// Singleton
export const localAiService = new LocalAiService();
