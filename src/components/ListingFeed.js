import { listingRepository } from '../storage/ListingRepository.js';
import { categories, getCategoryById } from '../data/categories.js';
import { router } from '../router/Router.js';
import { icon } from './icons.js';

let activeCategoryFilter = 'all';
let searchQuery = '';

function getRelativeTime(dateStr) {
  const now = new Date();
  const date = new Date(dateStr);
  const diff = Math.floor((now - date) / 1000);
  if (diff < 60) return 'just now';
  if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
  if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`;
  if (diff < 604800) return `${Math.floor(diff / 86400)}d ago`;
  return date.toLocaleDateString();
}

function truncateDescription(desc, maxLength = 110) {
  if (!desc) return '';
  if (desc.length <= maxLength) return desc;
  return desc.substring(0, maxLength) + '...';
}

function renderStatusBadge(status) {
  const statusMap = {
    'active': { label: 'Active', class: 'status-active' },
    'saved': { label: 'Saved', class: 'status-saved' },
    'contacted': { label: 'Contacted', class: 'status-contacted' },
    'closed': { label: 'Closed', class: 'status-closed' }
  };
  const config = statusMap[status] || statusMap['active'];
  return `<span class="badge ${config.class}">${config.label}</span>`;
}

function renderCategoryChips() {
  const chips = [
    `<button class="category-pill ${activeCategoryFilter === 'all' ? 'active' : ''}" data-category="all">
      <span class="category-icon">${icon('flash')}</span>
      <span class="category-label">All Items</span>
    </button>`
  ];
  
  categories.forEach(cat => {
    chips.push(
      `<button class="category-pill ${activeCategoryFilter === cat.id ? 'active' : ''}" data-category="${cat.id}">
        <span class="category-icon" style="font-size: 1.1rem;">${cat.icon}</span>
        <span class="category-label">${cat.name}</span>
      </button>`
    );
  });
  
  return `<div class="category-scroll-container">${chips.join('')}</div>`;
}

export async function renderListingFeed() {
  let listings = await listingRepository.getAll();
  
  // Category Filter
  if (activeCategoryFilter !== 'all') {
    listings = listings.filter(l => l.category === activeCategoryFilter);
  }

  // Search Filter
  if (searchQuery.trim()) {
    const q = searchQuery.toLowerCase().trim();
    listings = listings.filter(l => 
      l.title.toLowerCase().includes(q) || 
      l.description.toLowerCase().includes(q) ||
      l.area.toLowerCase().includes(q)
    );
  }
  
  // Sort by createdAt descending
  listings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  const totalCount = await listingRepository.count();

  let contentHtml = '';

  if (listings.length === 0) {
    contentHtml = `
      <div class="empty-state">
        <div class="empty-icon" style="font-size: 3rem; margin-bottom: 1rem; color: var(--blinkit-yellow);">
          ${icon('search')}
        </div>
        <h3>No matching listings found</h3>
        <p style="color: var(--text-muted); margin-bottom: 1.5rem;">Try adjusting your search or explore other categories in Bandra West.</p>
        <a href="#/create" class="btn btn-primary">
          ${icon('plus')} Create Listing
        </a>
      </div>
    `;
  } else {
    const cardsHtml = listings.map((listing, index) => {
      const category = getCategoryById(listing.category) || categories[0] || { icon: '📌', name: 'Other', color: '#0C831F' };
      const isOffer = listing.type === 'offer';
      
      return `
        <article class="listing-card blinkit-card animate-in" style="animation-delay: ${index * 0.04}s;" data-id="${listing.id}">
          <!-- Blinkit Delivery / Time Badge Header -->
          <div class="card-top-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div style="display: flex; align-items: center; gap: 6px;">
              <span class="blinkit-time-tag" style="background: rgba(247, 196, 19, 0.15); color: #D4A300; border: 1px solid rgba(247, 196, 19, 0.3); padding: 3px 8px; border-radius: var(--radius-pill); font-size: 0.72rem; font-weight: 800; display: inline-flex; align-items: center; gap: 3px;">
                ${icon('flash')} 8 MINS
              </span>
              <span class="category-tag" style="background: ${category.bg || 'rgba(12, 131, 31, 0.12)'}; color: ${category.color || 'var(--blinkit-green)'}; border: 1px solid rgba(12, 131, 31, 0.2); padding: 3px 8px; border-radius: var(--radius-pill); font-size: 0.72rem; font-weight: 700;">
                ${category.icon} ${category.name}
              </span>
            </div>
            ${renderStatusBadge(listing.status)}
          </div>

          <!-- Title & Description -->
          <h3 class="card-title" style="margin: 0 0 8px 0; font-size: 1.1rem; font-weight: 800; line-height: 1.3;">
            <a href="#/listing/${listing.id}" style="text-decoration: none; color: inherit;">${listing.title}</a>
          </h3>
          <p class="card-desc" style="color: var(--text-muted); font-size: 0.86rem; margin-bottom: 16px; flex-grow: 1; line-height: 1.5;">
            ${truncateDescription(listing.description)}
          </p>

          <!-- Area & Timing Pills (Blinkit style) -->
          <div class="card-meta-row" style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; font-size: 0.78rem;">
            <span style="background: var(--bg-dark-elevated-2); border: 1px solid var(--glass-border); padding: 3px 8px; border-radius: 6px; color: var(--text-main); font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
              ${icon('location')} ${listing.area}
            </span>
            <span style="background: ${isOffer ? 'rgba(12, 131, 31, 0.15)' : 'rgba(226, 55, 68, 0.15)'}; color: ${isOffer ? 'var(--blinkit-green)' : 'var(--zomato-red)'}; padding: 3px 8px; border-radius: 6px; font-weight: 800; text-transform: uppercase;">
              ${isOffer ? '📤 Offer' : '📥 Request'}
            </span>
            <span style="color: var(--text-muted); padding: 3px 0; margin-left: auto; display: inline-flex; align-items: center; gap: 3px;">
              ${icon('clock')} ${getRelativeTime(listing.createdAt)}
            </span>
          </div>

          <!-- Bottom Blinkit ADD / VIEW Action Button -->
          <div class="card-action-bar" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed var(--glass-border); padding-top: 12px; margin-top: auto;">
            <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600; display: inline-flex; align-items: center; gap: 4px;">
              ${icon('chat')} ${listing.contactPreference || 'Chat'}
            </span>
            <a href="#/listing/${listing.id}" class="btn-blinkit-add" style="display: inline-flex; align-items: center; gap: 4px;">
              ADD <span style="font-size: 0.9rem;">+</span>
            </a>
          </div>
        </article>
      `;
    }).join('');

    contentHtml = `<div class="grid grid-3">${cardsHtml}</div>`;
  }

  return `
    <section class="page-container" aria-label="Listing Feed" style="padding-top: 84px;">
      <!-- Hero Blinkit Style Header Banner -->
      <div class="hero-banner-blinkit" style="background: var(--grad-hero); border: 1px solid rgba(247, 196, 19, 0.3); border-radius: var(--radius-md); padding: 22px 24px; margin-bottom: 20px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px; position: relative; overflow: hidden;">
        <div style="z-index: 1;">
          <div style="display: inline-flex; align-items: center; gap: 6px; background: var(--blinkit-yellow); color: #0C831F; font-size: 0.75rem; font-weight: 900; padding: 4px 10px; border-radius: var(--radius-pill); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">
            ${icon('flash')} Everything Delivered in 8 MINS • Bandra West
          </div>
          <h1 style="margin: 0 0 6px 0; font-size: clamp(1.4rem, 3vw, 2.2rem);">Local Goods, Tiffins & Services Instant Board</h1>
          <p style="color: var(--text-muted); margin: 0; font-size: 0.9rem;">${totalCount} verified neighborhood listings • 100% Offline-First & Private</p>
        </div>
        <a href="#/create" class="btn btn-primary btn-blinkit-hero" style="z-index: 1; display: inline-flex; align-items: center; gap: 6px;">
          ${icon('plus')} Post Listing
        </a>
      </div>

      <!-- Blinkit Style Instant Search Input with Icons -->
      <div class="search-bar-container" style="margin-bottom: 20px;">
        <div style="position: relative; width: 100%;">
          <input type="text" id="search-input" class="form-input" value="${searchQuery}" placeholder="Search 'tiffin', 'plumber', 'books', 'electronics' in Bandra West..." style="padding-left: 46px; padding-right: 40px; height: 50px; font-size: 0.95rem; border-radius: var(--radius-pill); background: var(--bg-dark-elevated-2); border: 1.5px solid var(--glass-border);" />
          <span style="position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--blinkit-yellow); display: flex; align-items: center;">
            ${icon('search')}
          </span>
          ${searchQuery ? `
            <button id="clear-search-btn" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--text-muted); cursor: pointer; display: flex; align-items: center;">
              ${icon('clear')}
            </button>
          ` : ''}
        </div>
      </div>

      <!-- Category Filter Pills (Story style) -->
      <div style="margin-bottom: 24px;">
        <div style="font-size: 0.75rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.08em; color: var(--text-muted); margin-bottom: 10px;">
          Categories in Bandra West
        </div>
        ${renderCategoryChips()}
      </div>

      <!-- Listings Grid -->
      ${contentHtml}
    </section>
  `;
}

export function initListingFeed() {
  const container = document.querySelector('.page-container[aria-label="Listing Feed"]');
  if (!container) return;

  // Search Input Handler
  const searchInput = container.querySelector('#search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      searchQuery = e.target.value;
      reRenderFeed();
    });
  }

  const clearSearchBtn = container.querySelector('#clear-search-btn');
  if (clearSearchBtn) {
    clearSearchBtn.addEventListener('click', () => {
      searchQuery = '';
      reRenderFeed();
    });
  }

  // Category filter pills
  const categoryPills = container.querySelectorAll('.category-pill');
  categoryPills.forEach(pill => {
    pill.addEventListener('click', (e) => {
      const target = e.currentTarget;
      activeCategoryFilter = target.dataset.category;
      reRenderFeed();
    });
  });

  // Card clicks
  const cards = container.querySelectorAll('.listing-card');
  cards.forEach(card => {
    card.addEventListener('click', (e) => {
      if (e.target.tagName.toLowerCase() !== 'a' && !e.target.closest('a')) {
        const id = card.dataset.id;
        if (id && router && router.navigate) {
          router.navigate(`/listing/${id}`);
        } else if (id) {
          window.location.hash = `/listing/${id}`;
        }
      }
    });
  });

  async function reRenderFeed() {
    const root = document.getElementById('app-root');
    if (root) {
      root.innerHTML = await renderListingFeed();
      initListingFeed();
      // Keep focus on search input if typing
      const newSearchInput = root.querySelector('#search-input');
      if (newSearchInput && searchQuery) {
        newSearchInput.focus();
        newSearchInput.setSelectionRange(searchQuery.length, searchQuery.length);
      }
    }
  }
}
