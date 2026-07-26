import { listingRepository } from '../storage/ListingRepository.js';
import { categories, getCategoryById } from '../data/categories.js';
import { localAiService } from '../ai/LocalAiService.js';
import { router } from '../router/Router.js';
import { icon } from './icons.js';

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
  
  let scoreColor = 'var(--blinkit-green)';
  if (communityScore < 40) {
    scoreColor = 'var(--zomato-red)';
  } else if (communityScore < 70) {
    scoreColor = 'var(--blinkit-yellow)';
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

  // Recent Activity
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
          <span style="font-size:1.4rem" aria-hidden="true">${cat ? cat.icon : '📦'}</span>
          <div>
            <div style="font-weight:700;color:var(--text-main);font-size:0.95rem;">${l.title}</div>
            <div style="font-size:0.75rem;color:var(--text-muted);display:flex;align-items:center;gap:4px;">
              ${icon('clock')} ${getRelativeTime(l.createdAt)}
            </div>
          </div>
        </div>
        <span class="badge status-${l.status}">${l.status}</span>
      </div>
    `;
  }).join('') : '<p style="color:var(--text-muted);padding:12px">No recent activity.</p>';
  
  // AI Status
  const aiStatus = localAiService.getStatus();
  const aiText = aiStatus.modelAvailable ? 'Local model' : 'Deterministic fallback (Offline)';
  const aiDotColor = aiStatus.modelAvailable ? 'var(--blinkit-green)' : 'var(--blinkit-yellow)';
  
  return `
    <style>
      .category-bar { display: flex; align-items: center; gap: 12px; margin-bottom: 12px; }
      .category-bar-label { min-width: 130px; font-size: 0.875rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-weight: 600; }
      .category-bar-track { flex: 1; height: 20px; background: var(--bg-dark-elevated-2); border-radius: var(--radius-pill); overflow: hidden; border: 1px solid var(--glass-border); }
      .category-bar-fill { height: 100%; border-radius: var(--radius-pill); transition: width 0.5s ease; min-width: 4px; }
      .category-bar-count { min-width: 32px; text-align: right; font-family: var(--font-mono); font-size: 0.875rem; color: var(--text-muted); font-weight: 700; }
      .recent-listing-item:hover { background: var(--glass-bg-hover); }
    </style>
    
    <div class="page-container animate-in" style="padding-top: 84px;">
      <div class="page-header" style="background: var(--grad-hero); border: 1px solid rgba(247, 196, 19, 0.3); padding: 22px 24px; border-radius: var(--radius-md); margin-bottom: 24px;">
        <div style="display: inline-flex; align-items: center; gap: 6px; background: var(--blinkit-yellow); color: #0C831F; font-size: 0.75rem; font-weight: 900; padding: 4px 10px; border-radius: var(--radius-pill); text-transform: uppercase; margin-bottom: 8px;">
          ${icon('pulse')} Real-Time Analytics
        </div>
        <h1 style="margin:0 0 6px 0;">Neighborhood Pulse</h1>
        <p style="color:var(--text-muted);margin:0;">Bandra West community health score & active category metrics</p>
      </div>
      
      <!-- Stats Grid -->
      <div class="grid grid-3" style="margin-bottom:28px">
        <div class="stat-card" style="border-left: 4px solid var(--blinkit-yellow);">
          <div class="stat-label">Total Listings</div>
          <div class="stat-value">${totalListings}</div>
        </div>
        <div class="stat-card" style="border-left: 4px solid var(--blinkit-green);">
          <div class="stat-label">Active Listings</div>
          <div class="stat-value" style="color: var(--blinkit-green);">${activeListings}</div>
        </div>
        <div class="stat-card" style="border-left: 4px solid ${scoreColor};">
          <div class="stat-label">Community Score</div>
          <div class="stat-value" style="color:${scoreColor}">${communityScore}%</div>
        </div>
      </div>
      
      <!-- Category Breakdown Bar Chart -->
      <div class="pulse-card" style="margin-bottom:24px; padding: 24px;">
        <h2 style="font-size:1.15rem;margin-bottom:18px;display:flex;align-items:center;gap:8px;">
          Category Distribution in Bandra W
        </h2>
        ${categoryHtml}
      </div>
      
      <!-- Recent Activity + AI Status -->
      <div class="grid grid-2">
        <div class="pulse-card" style="padding: 24px;">
          <h2 style="font-size:1.15rem;margin-bottom:16px;">Recent Activity</h2>
          ${recentHtml}
        </div>
        <div class="pulse-card" style="padding: 24px;">
          <h2 style="font-size:1.15rem;margin-bottom:16px;display:flex;align-items:center;gap:6px;">
            ${icon('bot', 'var(--blinkit-yellow)')} Local AI Status
          </h2>
          <div style="display:flex;align-items:center;padding:16px;background:var(--bg-dark-elevated-2);border-radius:var(--radius-md);border:1px solid var(--glass-border);">
            <span style="display:inline-block;width:10px;height:10px;border-radius:50%;background:${aiDotColor};margin-right:10px;" aria-hidden="true"></span>
            <strong style="font-size: 0.95rem;">AI Service: ${aiText}</strong>
          </div>
          <p style="margin-top:16px;font-size:0.875rem;color:var(--text-muted);line-height:1.6;">
            MAL Local operates with zero remote server dependency. AI suggestions generate instantly using local template fallbacks or browser-embedded models.
          </p>
          <div style="margin-top:14px;font-size:0.82rem;color:var(--text-muted);display:flex;flex-direction:column;gap:6px;">
            <div style="display:flex;align-items:center;gap:6px;">${icon('shieldCheck', 'var(--blinkit-green)')} Privacy: 100% On-Device</div>
            <div style="display:flex;align-items:center;gap:6px;">${icon('check', 'var(--blinkit-green)')} Offline Fallback: Always Available</div>
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
