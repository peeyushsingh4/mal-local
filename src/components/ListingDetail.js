import { listingRepository } from '../storage/ListingRepository.js';
import { getCategoryById } from '../data/categories.js';
import { router } from '../router/Router.js';
import { showToast } from './Toast.js';

/**
 * Render the listing detail page.
 * @param {string} id - Listing ID to display
 * @returns {Promise<string>} HTML string
 */
export async function renderListingDetail(id) {
  const listing = await listingRepository.getById(id);
  
  if (!listing) {
    return `
      <div class="page-container animate-in">
        <div class="empty-state">
          <div style="font-size:3rem" aria-hidden="true">🔍</div>
          <h1>Listing not found</h1>
          <p>This listing may have been deleted or doesn't exist.</p>
          <a href="#/" class="btn btn-primary">Back to Feed</a>
        </div>
      </div>
    `;
  }
  
  const category = getCategoryById(listing.category) || { name: 'Unknown', icon: '❓' };
  const date = new Date(listing.createdAt || Date.now()).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  const getContactIcon = (pref) => {
    switch(pref) {
      case 'chat': return '💬 Chat';
      case 'call': return '📞 Call';
      case 'whatsapp': return '📱 WhatsApp';
      case 'in-person': return '🤝 In Person';
      default: return '💬 Chat';
    }
  };

  const statusIcons = { active: '●', saved: '★', contacted: '✉', closed: '✕' };

  const getActionButtons = (status) => {
    let buttons = '';
    
    if (status === 'active') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="saved" aria-label="Save listing">★ Save</button>`;
      buttons += `<button type="button" class="btn btn-primary action-btn" data-action="contacted" aria-label="Mark as contacted">✉ Mark Contacted</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing">✕ Close Listing</button>`;
    } else if (status === 'saved') {
      buttons += `<button type="button" class="btn btn-primary action-btn" data-action="contacted" aria-label="Mark as contacted">✉ Mark Contacted</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing">✕ Close Listing</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    } else if (status === 'contacted') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing">✕ Close Listing</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    } else if (status === 'closed') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    }
    
    buttons += `<button type="button" class="btn btn-danger delete-btn" aria-label="Delete listing">🗑 Delete</button>`;
    return buttons;
  };

  const status = listing.status || 'active';

  return `
    <div class="page-container animate-in">
      <a href="#/" class="btn btn-ghost" style="margin-bottom:16px;padding:0;min-height:auto">← Back to feed</a>
      
      <article class="listing-card" style="padding:28px" aria-labelledby="detail-title">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;flex-wrap:wrap;gap:8px">
          <div style="display:flex;gap:8px;flex-wrap:wrap">
            <span class="badge" style="border:1px solid ${category.color || 'var(--glass-border)'};border-radius:var(--radius-pill);padding:4px 12px;font-size:12px">
              ${category.icon} ${category.name}
            </span>
            <span class="badge status-${status}" style="border-radius:var(--radius-pill);padding:4px 12px;font-size:12px;text-transform:capitalize">
              ${statusIcons[status] || '●'} ${status}
            </span>
            ${listing.type ? `<span class="chip" style="font-size:12px;text-transform:capitalize">${listing.type === 'offer' ? '📤' : '📥'} ${listing.type}</span>` : ''}
          </div>
        </div>
        
        <h1 id="detail-title" style="margin-top:0;margin-bottom:16px">${listing.title}</h1>
        
        <p style="white-space:pre-wrap;margin-bottom:24px;line-height:1.7;color:var(--text-muted)">${listing.description}</p>
        
        <div style="display:flex;flex-wrap:wrap;gap:20px;margin-bottom:24px;font-size:14px;color:var(--text-muted)">
          <div style="display:flex;align-items:center;gap:6px">
            <span aria-hidden="true">📍</span> <span>${listing.area}</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px">
            <span>${getContactIcon(listing.contactPreference)}</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px">
            <span aria-hidden="true">📅</span> <time datetime="${listing.createdAt}">${date}</time>
          </div>
          ${listing.aiGenerated ? `<span class="chip">🤖 AI-assisted</span>` : ''}
        </div>
        
        <hr style="border:0;border-top:1px solid var(--glass-border);margin:24px 0" />
        
        <div style="display:flex;flex-wrap:wrap;gap:12px;align-items:center" id="action-buttons-container">
          ${getActionButtons(status)}
        </div>
      </article>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="delete-modal-overlay">
      <div class="modal" role="dialog" aria-labelledby="delete-modal-title" aria-modal="true">
        <h2 id="delete-modal-title">🗑 Delete Listing</h2>
        <p style="color:var(--text-muted);margin:16px 0">Are you sure you want to delete this listing? This action cannot be undone.</p>
        <div style="display:flex;gap:12px;justify-content:flex-end">
          <button type="button" class="btn btn-ghost" id="cancel-delete">Cancel</button>
          <button type="button" class="btn btn-danger" id="confirm-delete">Delete</button>
        </div>
      </div>
    </div>
  `;
}

/**
 * Initialize event handlers for the listing detail page.
 * @param {string} id - Listing ID
 */
export function initListingDetail(id) {
  const container = document.getElementById('action-buttons-container');
  if (!container) return; // Not found state

  // Status update handler
  const updateStatus = async (newStatus) => {
    try {
      await listingRepository.update(id, { status: newStatus });
      showToast(`Listing marked as ${newStatus}`, 'success');
      // Re-render the detail page
      const { renderListingDetail: rerender, initListingDetail: reinit } = await import('./ListingDetail.js');
      const root = document.getElementById('app-root');
      if (root) {
        root.innerHTML = await rerender(id);
        reinit(id);
      }
    } catch (error) {
      showToast('Failed to update status', 'error');
      console.error('[ListingDetail] Update error:', error);
    }
  };

  // Action buttons
  container.addEventListener('click', (e) => {
    const btn = e.target.closest('.action-btn');
    if (!btn) return;
    const action = btn.dataset.action;
    if (action) updateStatus(action);
  });

  // Delete modal
  const deleteBtn = container.querySelector('.delete-btn');
  const overlay = document.getElementById('delete-modal-overlay');
  const cancelBtn = document.getElementById('cancel-delete');
  const confirmBtn = document.getElementById('confirm-delete');

  if (deleteBtn && overlay) {
    deleteBtn.addEventListener('click', () => {
      overlay.classList.add('active');
    });

    const closeModal = () => {
      overlay.classList.remove('active');
    };

    if (cancelBtn) cancelBtn.addEventListener('click', closeModal);

    // Close on overlay click
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) closeModal();
    });

    // Close on Escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && overlay.classList.contains('active')) {
        closeModal();
      }
    });

    if (confirmBtn) {
      confirmBtn.addEventListener('click', async () => {
        try {
          await listingRepository.delete(id);
          showToast('Listing deleted successfully', 'success');
          closeModal();
          router.navigate('/');
        } catch (error) {
          showToast('Failed to delete listing', 'error');
          closeModal();
        }
      });
    }
  }
}
