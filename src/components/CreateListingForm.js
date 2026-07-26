import { listingRepository } from '../storage/ListingRepository.js';
import { Listing } from '../models/Listing.js';
import { categories } from '../data/categories.js';
import { localAiService } from '../ai/LocalAiService.js';
import { router } from '../router/Router.js';
import { showToast } from './Toast.js';
import { icon } from './icons.js';

export function renderCreateListingForm() {
  return `
    <div class="page-container animate-in" style="padding-top: 84px;">
      <div class="page-header" style="background: var(--grad-hero); border: 1px solid rgba(247, 196, 19, 0.3); padding: 24px; border-radius: var(--radius-md); margin-bottom: 24px;">
        <div style="display: inline-flex; align-items: center; gap: 6px; background: var(--blinkit-yellow); color: #0C831F; font-size: 0.75rem; font-weight: 900; padding: 4px 10px; border-radius: var(--radius-pill); text-transform: uppercase; margin-bottom: 8px;">
          ${icon('flash')} 8 MINS Instant Posting
        </div>
        <h1 style="margin: 0 0 6px 0;">Create a Neighborhood Listing</h1>
        <p style="color:var(--text-muted); margin: 0;">Share food, services, goods, or help requests with residents in Bandra West</p>
      </div>

      <form id="create-listing-form" novalidate style="background: var(--bg-dark-elevated); border: 1px solid var(--glass-border); padding: 28px; border-radius: var(--radius-md); box-shadow: var(--shadow-sm);">
        <div id="form-error-summary" aria-live="polite" class="visually-hidden"></div>
        
        <!-- Title -->
        <div class="form-group" id="group-title">
          <label class="form-label" for="listing-title">Listing Title *</label>
          <input class="form-input" type="text" id="listing-title" name="title" 
            placeholder="e.g., Home-cooked Maharashtrian Tiffin Packs" 
            required aria-required="true" minlength="3" maxlength="100" />
          <div id="error-title" aria-live="polite"></div>
        </div>
        
        <!-- Category -->
        <div class="form-group" id="group-category">
          <label class="form-label" for="listing-category">Category *</label>
          <select class="form-select" id="listing-category" name="category" required aria-required="true">
            <option value="">Select a category</option>
            ${categories.map(c => `<option value="${c.id}">${c.icon} ${c.name}</option>`).join('')}
          </select>
          <div id="error-category" aria-live="polite"></div>
        </div>
        
        <!-- Type -->
        <div class="form-group">
          <span class="form-label">Type</span>
          <div style="display:flex;gap:16px;margin-top:4px">
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:600;">
              <input type="radio" name="type" value="offer" checked /> 📤 Offer (Sharing/Selling)
            </label>
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-weight:600;">
              <input type="radio" name="type" value="request" /> 📥 Request (Looking for)
            </label>
          </div>
        </div>
        
        <!-- Description with AI -->
        <div class="form-group" id="group-description">
          <label class="form-label" for="listing-description">Description *</label>
          <textarea class="form-textarea" id="listing-description" name="description"
            placeholder="Describe what you're offering or looking for in detail..."
            required aria-required="true" minlength="10" maxlength="1000"></textarea>
          <div style="display:flex;justify-content:space-between;align-items:center;gap:8px;margin-top:6px;">
            <button type="button" id="ai-suggest-btn" class="btn btn-ghost" style="font-size:0.85rem;min-height:38px;padding:0 14px;border: 1px solid var(--blinkit-yellow);color: var(--text-main);background: rgba(247, 196, 19, 0.1);display:inline-flex;align-items:center;gap:6px;">
              ${icon('sparkles', '#F7C413')} AI Description Helper
            </button>
            <span id="ai-badge" style="display:none;align-items:center;gap:4px;" class="chip">
              ${icon('bot')} AI-assisted
            </span>
          </div>
          <div id="error-description" aria-live="polite"></div>
        </div>
        
        <!-- Area -->
        <div class="form-group" id="group-area">
          <label class="form-label" for="listing-area">Neighborhood Area *</label>
          <input class="form-input" type="text" id="listing-area" name="area"
            placeholder="e.g., Pali Hill, Carter Road, Hill Road"
            required aria-required="true" />
          <small style="color:var(--text-muted);font-size:0.8rem">Use a general neighborhood area name, not an exact house address</small>
          <div id="error-area" aria-live="polite"></div>
        </div>
        
        <!-- Contact Preference -->
        <div class="form-group">
          <label class="form-label" for="listing-contact">Contact Preference</label>
          <select class="form-select" id="listing-contact" name="contactPreference">
            <option value="chat">💬 Chat</option>
            <option value="call">📞 Call</option>
            <option value="whatsapp">📱 WhatsApp</option>
            <option value="in-person">🤝 In Person</option>
          </select>
        </div>
        
        <!-- Submit -->
        <div style="display:flex;gap:12px;margin-top:24px">
          <button type="submit" class="btn btn-primary btn-blinkit-hero" id="submit-btn" style="display:inline-flex;align-items:center;gap:6px;">
            ${icon('plus')} Create Listing
          </button>
          <a href="#/" class="btn btn-secondary">Cancel</a>
        </div>
      </form>
    </div>
  `;
}

export function initCreateListingForm() {
  const form = document.getElementById('create-listing-form');
  const aiSuggestBtn = document.getElementById('ai-suggest-btn');
  const titleInput = document.getElementById('listing-title');
  const categorySelect = document.getElementById('listing-category');
  const descriptionInput = document.getElementById('listing-description');
  const aiBadge = document.getElementById('ai-badge');
  const formErrorSummary = document.getElementById('form-error-summary');
  const submitBtn = document.getElementById('submit-btn');
  
  let aiGenerated = false;

  const clearError = (field) => {
    const errorDiv = document.getElementById(`error-${field}`);
    const input = document.getElementById(`listing-${field}`);
    if (errorDiv) errorDiv.innerHTML = '';
    if (input) {
      input.classList.remove('form-error');
      input.removeAttribute('aria-invalid');
    }
  };

  const inputs = ['title', 'category', 'description', 'area'];
  inputs.forEach(field => {
    const el = document.getElementById(`listing-${field}`);
    if (el) {
      el.addEventListener('input', () => clearError(field));
      el.addEventListener('change', () => clearError(field));
    }
  });

  aiSuggestBtn.addEventListener('click', async () => {
    const title = titleInput.value.trim();
    const category = categorySelect.value;
    
    if (!title || !category) {
      showToast('Please enter a title and select a category first', 'error');
      if (!title) {
        document.getElementById('error-title').innerHTML = `<span class="error-message">⚠ Title is required for AI suggestion</span>`;
        titleInput.classList.add('form-error');
        titleInput.setAttribute('aria-invalid', 'true');
        titleInput.setAttribute('aria-describedby', 'error-title');
      }
      if (!category) {
        document.getElementById('error-category').innerHTML = `<span class="error-message">⚠ Category is required for AI suggestion</span>`;
        categorySelect.classList.add('form-error');
        categorySelect.setAttribute('aria-invalid', 'true');
        categorySelect.setAttribute('aria-describedby', 'error-category');
      }
      return;
    }

    aiSuggestBtn.disabled = true;
    const originalText = aiSuggestBtn.innerHTML;
    aiSuggestBtn.innerHTML = `${icon('sparkles')} Generating...`;

    try {
      const result = await localAiService.suggestDescription(title, category);
      descriptionInput.value = result.description;
      clearError('description');
      aiBadge.style.display = 'inline-flex';
      aiGenerated = true;
    } catch (error) {
      showToast('Failed to generate description', 'error');
    } finally {
      aiSuggestBtn.disabled = false;
      aiSuggestBtn.innerHTML = originalText;
    }
  });

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    inputs.forEach(clearError);
    formErrorSummary.textContent = '';
    
    const formData = new FormData(form);
    const listingData = {
      title: formData.get('title').trim(),
      category: formData.get('category'),
      type: formData.get('type'),
      description: formData.get('description').trim(),
      area: formData.get('area').trim(),
      contactPreference: formData.get('contactPreference')
    };

    const listing = new Listing(listingData);
    const { valid, errors } = listing.validate();

    if (!valid) {
      const errorCount = Object.keys(errors).length;
      formErrorSummary.textContent = `Form contains ${errorCount} error${errorCount !== 1 ? 's' : ''}. Please fix them to proceed.`;
      
      for (const [field, message] of Object.entries(errors)) {
        const errorDiv = document.getElementById(`error-${field}`);
        const input = document.getElementById(`listing-${field}`);
        if (errorDiv && input) {
          errorDiv.innerHTML = `<span class="error-message">⚠ ${message}</span>`;
          input.classList.add('form-error');
          input.setAttribute('aria-invalid', 'true');
          input.setAttribute('aria-describedby', `error-${field}`);
        }
      }
      return;
    }

    if (aiGenerated) {
      listing.aiGenerated = true;
    }

    submitBtn.disabled = true;
    submitBtn.textContent = 'Saving...';

    try {
      await listingRepository.save(listing);
      showToast('Listing created successfully!', 'success');
      router.navigate('#/');
    } catch (error) {
      showToast('Failed to create listing', 'error');
      submitBtn.disabled = false;
      submitBtn.textContent = 'Create Listing';
    }
  });
}
