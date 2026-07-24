import { listingRepository } from '../storage/ListingRepository.js';
import { categories, getCategoryById } from '../data/categories.js';
import { localAiService } from '../ai/LocalAiService.js';
import { router } from '../router/Router.js';

/**
 * Get relative time string from an ISO date string.
 */
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

export async function renderNeighborhoodPulse() {
  const allListings = await listingRepository.getAll();
  const totalListings = allListings.length;
  
  const activeListings = allListings.filter(l => l.status === 'active').length;
  const totalCategories = categories.length;
  
  const communityScore = Math.min(100, Math.round((activeListings / Math.max(totalListings, 1)) * 100 + (totalCategories * 10)));
  
  let scoreColor = 'var(--accent-green)';
  if (communityScore < 40) {
    scoreColor = 'var(--accent-coral)';
  } else if (communityScore < 70) {
    scoreColor = 'var(--accent-purple)';
  }
  
  // Category Breakdown
  const categoryCounts = {};
  categories.forEach(c => categoryCounts[c.id] = 0);
  allListings.forEach(l => {
    if (categoryCounts[l.category] !== undefined) {
      categoryCounts[l.category]++;
    }
  });
  
  const sortedCategories = categories
    .map(c => ({ ...c, count: categoryCounts[c.id] }))
    .sort((a, b) => b.count - a.count);
    
  const maxCount = Math.max(...sortedCategories.map(c => c.count), 1);
  
  const categoryHtml = sortedCategories.map(c => `
    <div class="category-bar">
      <span class="category-bar-label">${c.icon} ${c.name}</span>
      <div class="category-bar-track">
        <div class="category-bar-fill" style="width: ${(c.count / maxCount) * 100}%; background: ${c.color}"></div>
      </div>
      <span class="category-bar-count">${c.count}</span>
    </div>
  `).join('');

  // Recent Activity (sorted by createdAt descending)
  const recentListings = [...allListings]
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, 5);
    
  const recentHtml = recentListings.length ? recentListings.map(l => {
    const cat = getCategoryById(l.category);
    return `
      <div class="recent-listing-item" data-id="${l.id}" tabindex="0" role="button" 
           aria-label="View ${l.title}" 
           style="display:flex;align-items:center;justify-content:space-between;padding:12px;border-bottom:1px solid var(--glass-border);cursor:pointer;">
        <div style="display:flex;align-items:center;gap:12px;">
          <span style="font-size:1.5rem" aria-hidden="true">${cat ? cat.icon : '📦'}</span>
          <div>
            <div style="font-weight:600;color:var(--text-main)">${l.title}</div>
            <div style="font-size:0.75rem;color:var(--text-muted)">${getRelativeTime(l.createdAt)}</div>
          </div>
        </div>
        <span class="badge status-${l.status}">${l.status}</span>
      </div>
    `;
  }).join('') : '<p style="color:var(--text-muted);padding:12px">No recent activity.</p>';
  
  // AI Status
  const aiStatus = localAiService.getStatus();
  const aiText = aiStatus.modelAvailable ? 'Local model' : 'Template fallback';
  const aiDotColor = aiStatus.modelAvailable ? 'var(--accent-green)' : 'var(--text-muted)';
  
  return `
    <style>
      .category-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
      .category-bar-label { min-width: 120px; font-size: 0.875rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
      .category-bar-track { flex: 1; height: 24px; background: var(--glass-bg); border-radius: var(--radius-pill); overflow: hidden; }
      .category-bar-fill { height: 100%; border-radius: var(--radius-pill); transition: width 0.5s ease; min-width: 2px; }
      .category-bar-count { min-width: 32px; text-align: right; font-family: var(--font-mono); font-size: 0.875rem; color: var(--text-muted); }
      .recent-listing-item:hover { background: var(--glass-bg-hover); }
    </style>
    
    <div class="page-container animate-in">
      <div class="page-header">
        <h1>Neighborhood Pulse</h1>
        <p style="color:var(--text-muted)">Bandra West community activity</p>
      </div>
      
      <!-- Stats -->
      <div class="grid grid-3" style="margin-bottom:32px">
        <div class="stat-card">
          <div class="stat-label">Total Listings</div>
          <div class="stat-value">${totalListings}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active Listings</div>
          <div class="stat-value">${activeListings}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Community Score</div>
          <div class="stat-value" style="color:${scoreColor}">${communityScore}%</div>
        </div>
      </div>
      
      <!-- Category Breakdown -->
      <div class="pulse-card" style="margin-bottom:24px">
        <h2 style="font-size:1.1rem;margin-bottom:16px">Category Activity</h2>
        ${categoryHtml}
      </div>
      
      <!-- Recent + AI Status -->
      <div class="grid grid-2">
        <div class="pulse-card">
          <h2 style="font-size:1.1rem;margin-bottom:16px">Recent Activity</h2>
          ${recentHtml}
        </div>
        <div class="pulse-card">
          <h2 style="font-size:1.1rem;margin-bottom:16px">AI Status</h2>
          <div style="display:flex;align-items:center;padding:16px;background:var(--glass-bg);border-radius:var(--radius-md)">
            <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:${aiDotColor};margin-right:10px" aria-hidden="true"></span>
            <strong>🤖 AI: ${aiText}</strong>
          </div>
          <p style="margin-top:16px;font-size:0.875rem;color:var(--text-muted)">
            MAL Local uses local AI for description suggestions. No data is sent to external servers.
          </p>
          <div style="margin-top:12px;font-size:0.8rem;color:var(--text-muted)">
            <div>Initialized: ${aiStatus.initialized ? '✓ Yes' : '✗ No'}</div>
            <div>Fallback available: ✓ Always</div>
          </div>
        </div>
      </div>
    </div>
  `;
}

export function initNeighborhoodPulse() {
  document.querySelectorAll('.recent-listing-item').forEach(item => {
    item.addEventListener('click', () => {
      const id = item.getAttribute('data-id');
      if (id) {
        router.navigate(`/listing/${id}`);
      }
    });
    // Keyboard accessibility
    item.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        const id = item.getAttribute('data-id');
        if (id) {
          router.navigate(`/listing/${id}`);
        }
      }
    });
  });
}
