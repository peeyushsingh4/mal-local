import { listingRepository } from '../storage/ListingRepository.js';
import { Listing } from '../models/Listing.js';
import { categories } from '../data/categories.js';
import { localAiService } from '../ai/LocalAiService.js';
import { router } from '../router/Router.js';
import { showToast } from './Toast.js';

export function renderCreateListingForm() {
  return `
    <div class="page-container animate-in">
      <div class="page-header">
        <h1>Create a Listing</h1>
        <p style="color:var(--text-muted)">Share something with your neighborhood</p>
      </div>
      <form id="create-listing-form" novalidate>
        <div id="form-error-summary" aria-live="polite" class="visually-hidden"></div>
        
        <!-- Title -->
        <div class="form-group" id="group-title">
          <label class="form-label" for="listing-title">Title *</label>
          <input class="form-input" type="text" id="listing-title" name="title" 
            placeholder="e.g., Home-cooked Maharashtrian Tiffin" 
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
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
              <input type="radio" name="type" value="offer" checked /> Offer
            </label>
            <label style="display:flex;align-items:center;gap:8px;cursor:pointer">
              <input type="radio" name="type" value="request" /> Request
            </label>
          </div>
        </div>
        
        <!-- Description with AI -->
        <div class="form-group" id="group-description">
          <label class="form-label" for="listing-description">Description *</label>
          <textarea class="form-textarea" id="listing-description" name="description"
            placeholder="Describe what you're offering or looking for..."
            required aria-required="true" minlength="10" maxlength="1000"></textarea>
          <div style="display:flex;justify-content:space-between;align-items:center;gap:8px">
            <button type="button" id="ai-suggest-btn" class="btn btn-ghost" style="font-size:13px;min-height:36px;padding:0 12px">
              ✨ AI Suggest
            </button>
            <span id="ai-badge" style="display:none" class="chip">🤖 AI-assisted</span>
          </div>
          <div id="error-description" aria-live="polite"></div>
        </div>
        
        <!-- Area -->
        <div class="form-group" id="group-area">
          <label class="form-label" for="listing-area">Area *</label>
          <input class="form-input" type="text" id="listing-area" name="area"
            placeholder="e.g., Pali Hill, Carter Road"
            required aria-required="true" />
          <small style="color:var(--text-muted);font-size:0.8rem">Use a neighborhood area name, not an exact address</small>
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
        <div style="display:flex;gap:12px;margin-top:16px">
          <button type="submit" class="btn btn-primary" id="submit-btn">Create Listing</button>
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
    aiSuggestBtn.innerHTML = '✨ Thinking...';

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
