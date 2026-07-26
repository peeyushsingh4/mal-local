import { listingRepository } from '../storage/ListingRepository.js';
import { getCategoryById } from '../data/categories.js';
import { router } from '../router/Router.js';
import { showToast } from './Toast.js';
import { icon } from './icons.js';

export async function renderListingDetail(id) {
  const listing = await listingRepository.getById(id);
  
  if (!listing) {
    return `
      <div class="page-container animate-in" style="padding-top: 84px;">
        <div class="empty-state">
          <div style="font-size:3rem;color:var(--blinkit-yellow)" aria-hidden="true">${icon('search')}</div>
          <h1>Listing Not Found</h1>
          <p>This listing may have been deleted or doesn't exist.</p>
          <a href="#/" class="btn btn-primary btn-blinkit-hero">
            ${icon('arrowLeft')} Back to Feed
          </a>
        </div>
      </div>
    `;
  }
  
  const category = getCategoryById(listing.category) || { name: 'Unknown', icon: '❓', color: '#0C831F' };
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

  const getActionButtons = (status) => {
    let buttons = '';
    
    if (status === 'active') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="saved" aria-label="Save listing" style="display:inline-flex;align-items:center;gap:6px;">${icon('bookmark')} Save</button>`;
      buttons += `<button type="button" class="btn btn-primary action-btn btn-blinkit-hero" data-action="contacted" aria-label="Mark as contacted" style="display:inline-flex;align-items:center;gap:6px;">${icon('chat')} Mark Contacted</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing" style="display:inline-flex;align-items:center;gap:6px;">✕ Close Listing</button>`;
    } else if (status === 'saved') {
      buttons += `<button type="button" class="btn btn-primary action-btn btn-blinkit-hero" data-action="contacted" aria-label="Mark as contacted" style="display:inline-flex;align-items:center;gap:6px;">${icon('chat')} Mark Contacted</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing">✕ Close Listing</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    } else if (status === 'contacted') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="closed" aria-label="Close listing">✕ Close Listing</button>`;
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    } else if (status === 'closed') {
      buttons += `<button type="button" class="btn btn-secondary action-btn" data-action="active" aria-label="Reactivate listing">↩ Reactivate</button>`;
    }
    
    buttons += `<button type="button" class="btn btn-danger delete-btn" aria-label="Delete listing" style="display:inline-flex;align-items:center;gap:6px;">${icon('trash')} Delete</button>`;
    return buttons;
  };

  const status = listing.status || 'active';

  return `
    <div class="page-container animate-in" style="padding-top: 84px;">
      <a href="#/" class="btn btn-ghost" style="margin-bottom:16px;padding:0;min-height:auto;display:inline-flex;align-items:center;gap:6px;">
        ${icon('arrowLeft')} Back to Feed
      </a>
      
      <article class="listing-card blinkit-card" style="padding:32px;box-shadow:var(--shadow-md);" aria-labelledby="detail-title">
        <!-- Blinkit Top Badges -->
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:10px">
          <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center;">
            <span class="blinkit-time-tag" style="background: rgba(247, 196, 19, 0.15); color: #D4A300; border: 1px solid rgba(247, 196, 19, 0.3); padding: 4px 10px; border-radius: var(--radius-pill); font-size: 0.78rem; font-weight: 800; display: inline-flex; align-items: center; gap: 4px;">
              ${icon('flash')} 8 MINS HYPERLOCAL
            </span>
            <span class="badge" style="background:${category.bg || 'rgba(12, 131, 31, 0.12)'};color:${category.color || 'var(--blinkit-green)'};border:1px solid rgba(12, 131, 31, 0.2);border-radius:var(--radius-pill);padding:4px 12px;font-size:12px;font-weight:700;">
              ${category.icon} ${category.name}
            </span>
            ${listing.type ? `<span class="chip" style="font-size:12px;font-weight:800;text-transform:uppercase;">${listing.type === 'offer' ? '📤 Offer' : '📥 Request'}</span>` : ''}
          </div>
          <span class="badge status-${status}" style="border-radius:var(--radius-pill);padding:4px 12px;font-size:12px;text-transform:capitalize;font-weight:800;">
            ${status}
          </span>
        </div>
        
        <h1 id="detail-title" style="margin-top:0;margin-bottom:16px;font-weight:800;">${listing.title}</h1>
        
        <p style="white-space:pre-wrap;margin-bottom:24px;line-height:1.7;color:var(--text-muted);font-size:1rem;">${listing.description}</p>
        
        <div style="display:flex;flex-wrap:wrap;gap:20px;margin-bottom:24px;font-size:14px;color:var(--text-muted);background:var(--bg-dark-elevated-2);padding:14px 18px;border-radius:var(--radius-sm);border:1px solid var(--glass-border);">
          <div style="display:flex;align-items:center;gap:6px;font-weight:600;">
            <span style="color:var(--swiggy-orange);">${icon('location')}</span> <span>${listing.area}</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px;font-weight:600;">
            <span>${getContactIcon(listing.contactPreference)}</span>
          </div>
          <div style="display:flex;align-items:center;gap:6px;">
            <span>${icon('clock')}</span> <time datetime="${listing.createdAt}">${date}</time>
          </div>
          ${listing.aiGenerated ? `<span class="chip" style="display:inline-flex;align-items:center;gap:4px;">${icon('bot')} AI-assisted</span>` : ''}
        </div>
        
        <hr style="border:0;border-top:1px dashed var(--glass-border);margin:24px 0" />
        
        <div style="display:flex;flex-wrap:wrap;gap:12px;align-items:center" id="action-buttons-container">
          ${getActionButtons(status)}
        </div>
      </article>
    </div>
    
    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="delete-modal-overlay">
      <div class="modal" role="dialog" aria-labelledby="delete-modal-title" aria-modal="true">
        <h2 id="delete-modal-title" style="display:flex;align-items:center;gap:8px;">${icon('trash', 'var(--zomato-red)')} Delete Listing</h2>
        <p style="color:var(--text-muted);margin:16px 0">Are you sure you want to delete this listing? This action cannot be undone.</p>
        <div style="display:flex;gap:12px;justify-content:flex-end">
          <button type="button" class="btn btn-ghost" id="cancel-delete">Cancel</button>
          <button type="button" class="btn btn-danger" id="confirm-delete">Delete</button>
        </div>
      </div>
    </div>
  `;
}

export function initListingDetail(id) {
  const container = document.getElementById('action-buttons-container');
  if (!container) return;

  const updateStatus = async (newStatus) => {
    try {
      await listingRepository.update(id, { status: newStatus });
      showToast(`Listing marked as ${newStatus}`, 'success');
      const { renderListingDetail: rerender, initListingDetail: reinit } = await import('./ListingDetail.js');
      const root = document.getElementById('app-root');
      if (root) {
        root.innerHTML = await rerender(id);
        reinit(id);
      }
    } catch (error) {
      showToast('Failed to update status', 'error');
    }
  };

  container.addEventListener('click', (e) => {
    const btn = e.target.closest('.action-btn');
    if (!btn) return;
    const action = btn.dataset.action;
    if (action) updateStatus(action);
  });

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

    overlay.addEventListener('click', (e) => {
      if (e.target === overlay) closeModal();
    });

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
