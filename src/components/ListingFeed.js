import { listingRepository } from '../storage/ListingRepository.js';
import { categories, getCategoryById } from '../data/categories.js';
import { router } from '../router/Router.js';

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
    'active': { icon: '●', label: 'Active', class: 'status-active' },
    'saved': { icon: '★', label: 'Saved', class: 'status-saved' },
    'contacted': { icon: '✉', label: 'Contacted', class: 'status-contacted' },
    'closed': { icon: '✕', label: 'Closed', class: 'status-closed' }
  };
  const config = statusMap[status] || statusMap['active'];
  return `<span class="badge ${config.class}">${config.icon} ${config.label}</span>`;
}

function renderCategoryChips() {
  const chips = [
    `<button class="category-pill ${activeCategoryFilter === 'all' ? 'active' : ''}" data-category="all">
      <span class="category-icon">⚡</span>
      <span class="category-label">All</span>
    </button>`
  ];
  
  categories.forEach(cat => {
    chips.push(
      `<button class="category-pill ${activeCategoryFilter === cat.id ? 'active' : ''}" data-category="${cat.id}">
        <span class="category-icon">${cat.icon}</span>
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
        <div class="empty-icon" style="font-size: 3.5rem; margin-bottom: 1rem;">🔍</div>
        <h3>No matching listings</h3>
        <p style="color: var(--text-muted); margin-bottom: 1.5rem;">Try adjusting your search or category filter, or post a new request.</p>
        <a href="#/create" class="btn btn-primary">Create Listing</a>
      </div>
    `;
  } else {
    const cardsHtml = listings.map((listing, index) => {
      const category = getCategoryById(listing.category) || categories[0] || { icon: '📌', name: 'Other', color: '#FC8019' };
      const isOffer = listing.type === 'offer';
      
      return `
        <article class="listing-card blinkit-card animate-in" style="animation-delay: ${index * 0.04}s;" data-id="${listing.id}">
          <!-- Card Header Banner -->
          <div class="card-top-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <span class="category-tag" style="background: rgba(252, 128, 25, 0.12); color: var(--swiggy-orange); border: 1px solid rgba(252, 128, 25, 0.3); padding: 4px 10px; border-radius: var(--radius-pill); font-size: 0.75rem; font-weight: 700;">
              ${category.icon} ${category.name}
            </span>
            ${renderStatusBadge(listing.status)}
          </div>

          <!-- Title & Description -->
          <h3 class="card-title" style="margin: 0 0 8px 0; font-size: 1.15rem; font-weight: 700; line-height: 1.3;">
            <a href="#/listing/${listing.id}" style="text-decoration: none; color: inherit;">${listing.title}</a>
          </h3>
          <p class="card-desc" style="color: var(--text-muted); font-size: 0.875rem; margin-bottom: 16px; flex-grow: 1; line-height: 1.5;">
            ${truncateDescription(listing.description)}
          </p>

          <!-- Area & Timing Pills (Blinkit style) -->
          <div class="card-meta-row" style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 16px; font-size: 0.78rem;">
            <span style="background: var(--bg-dark-elevated-2); border: 1px solid var(--glass-border); padding: 3px 8px; border-radius: 6px; color: var(--text-main); font-weight: 600;">
              📍 ${listing.area}
            </span>
            <span style="background: ${isOffer ? 'rgba(12, 131, 31, 0.15)' : 'rgba(226, 55, 68, 0.15)'}; color: ${isOffer ? 'var(--blinkit-green)' : 'var(--zomato-red)'}; padding: 3px 8px; border-radius: 6px; font-weight: 700; text-transform: uppercase;">
              ${isOffer ? '📤 Offer' : '📥 Request'}
            </span>
            <span style="color: var(--text-muted); padding: 3px 0; margin-left: auto;">
              ⏱️ ${getRelativeTime(listing.createdAt)}
            </span>
          </div>

          <!-- Bottom Action Bar (Swiggy / Blinkit style + ADD / VIEW button) -->
          <div class="card-action-bar" style="display: flex; justify-content: space-between; align-items: center; border-top: 1px dashed var(--glass-border); padding-top: 12px; margin-top: auto;">
            <span style="font-size: 0.8rem; color: var(--text-muted); font-weight: 500;">
              💬 ${listing.contactPreference || 'Chat'}
            </span>
            <a href="#/listing/${listing.id}" class="btn-blinkit-add">
              VIEW DETAILS ➜
            </a>
          </div>
        </article>
      `;
    }).join('');

    contentHtml = `<div class="grid grid-3">${cardsHtml}</div>`;
  }

  return `
    <section class="page-container" aria-label="Listing Feed" style="padding-top: 84px;">
      <!-- Hero Swiggy / Blinkit Banner -->
      <div class="hero-banner-blinkit" style="background: linear-gradient(135deg, rgba(252, 128, 25, 0.15), rgba(247, 196, 19, 0.12)); border: 1px solid rgba(252, 128, 25, 0.25); border-radius: var(--radius-md); padding: 24px; margin-bottom: 24px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px;">
        <div>
          <div style="display: inline-flex; align-items: center; gap: 6px; background: rgba(12, 131, 31, 0.2); color: var(--blinkit-green); font-size: 0.75rem; font-weight: 800; padding: 4px 10px; border-radius: var(--radius-pill); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">
            ⚡ Hyperlocal Delivery & Board • Bandra W
          </div>
          <h1 style="margin: 0 0 6px 0; font-size: clamp(1.5rem, 3vw, 2.2rem);">Discover & Share Goods, Tiffins & Help Nearby</h1>
          <p style="color: var(--text-muted); margin: 0; font-size: 0.95rem;">${totalCount} active listings in your Bandra West neighborhood • 100% Local-First</p>
        </div>
        <a href="#/create" class="btn btn-primary" style="background: var(--grad-primary); box-shadow: var(--shadow-glow);">
          ➕ Post a Listing
        </a>
      </div>

      <!-- Instant Search Bar -->
      <div class="search-bar-container" style="margin-bottom: 20px;">
        <div style="position: relative; width: 100%;">
          <input type="text" id="search-input" class="form-input" value="${searchQuery}" placeholder="🔍 Search tiffins, tutors, plumbers, books, electronics in Bandra West..." style="padding-left: 44px; height: 50px; font-size: 0.95rem; border-radius: var(--radius-pill); background: var(--bg-dark-elevated-2);" />
          <span style="position: absolute; left: 16px; top: 50%; transform: translateY(-50%); font-size: 1.1rem;">🔍</span>
          ${searchQuery ? `<button id="clear-search-btn" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--text-muted); font-size: 1rem; cursor: pointer;">✕</button>` : ''}
        </div>
      </div>

      <!-- Category Filter Pills (Story style) -->
      <div style="margin-bottom: 24px;">
        <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 10px;">
          Explore Categories
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
