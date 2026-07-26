import { icon } from './icons.js';

// Initialize theme from localStorage
(function initTheme() {
  if (typeof window !== 'undefined' && window.localStorage) {
    const saved = localStorage.getItem('mal-theme');
    if (saved === 'light') {
      document.documentElement.dataset.theme = 'light';
    }
  }
})();

export function renderNavigation() {
  const currentHash = window.location.hash.slice(1) || '/';
  const isLight = document.documentElement.dataset.theme === 'light';
  
  return `
    <div class="nav-container">
      <div class="nav-brand-group" style="display: flex; align-items: center; gap: 16px;">
        <a href="#/" class="brand-name" style="display: flex; align-items: center; gap: 8px; text-decoration: none;">
          <span class="blinkit-logo-badge" style="background: var(--blinkit-yellow); color: #0C831F; border-radius: 10px; padding: 4px 10px; font-family: var(--font-display); font-weight: 900; font-size: 1.15rem; letter-spacing: -0.03em; box-shadow: 0 4px 12px rgba(247, 196, 19, 0.4);">
            blinkit
          </span>
          <span style="font-family: var(--font-display); font-weight: 800; font-size: 1rem; color: var(--text-main); letter-spacing: 0.05em;">MAL LOCAL</span>
        </a>

        <!-- Blinkit Location & 8 MINS Delivery Pill -->
        <div class="blinkit-location-pill" style="display: flex; align-items: center; gap: 8px; background: var(--bg-dark-elevated-2); border: 1px solid var(--glass-border); padding: 4px 12px 4px 6px; border-radius: var(--radius-pill); font-size: 0.8rem; font-weight: 700; cursor: pointer;">
          <span style="background: var(--blinkit-yellow); color: #0C831F; padding: 3px 8px; border-radius: var(--radius-pill); font-size: 0.72rem; font-weight: 900; display: inline-flex; align-items: center; gap: 3px;">
            ${icon('flash')} 8 MINS
          </span>
          <span style="display: inline-flex; align-items: center; gap: 4px; color: var(--text-main);">
            ${icon('location')} Bandra West, Mumbai ▾
          </span>
        </div>
      </div>

      <div class="nav-links" style="display: flex; align-items: center; gap: 12px;">
        <a href="#/" class="nav-link ${currentHash === '/' ? 'active' : ''}" style="display: flex; align-items: center; gap: 6px;">
          ${icon('home')} Feed
        </a>
        <a href="#/create" class="nav-link nav-btn-cta ${currentHash === '/create' ? 'active' : ''}" style="display: flex; align-items: center; gap: 6px;">
          ${icon('plus')} Create Listing
        </a>
        <a href="#/pulse" class="nav-link ${currentHash === '/pulse' ? 'active' : ''}" style="display: flex; align-items: center; gap: 6px;">
          ${icon('pulse')} Pulse
        </a>
        <a href="#/settings" class="nav-link ${currentHash === '/settings' ? 'active' : ''}" style="display: flex; align-items: center; gap: 6px;">
          ${icon('settings')} Settings
        </a>
        <button class="theme-toggle" type="button" aria-label="${isLight ? 'Switch to dark theme' : 'Switch to light theme'}">
          ${isLight ? '🌙' : '☀️'}
        </button>
      </div>
    </div>
  `;
}

export function initNavigation() {
  const toggle = document.querySelector('.theme-toggle');
  if (toggle) {
    toggle.addEventListener('click', () => {
      const html = document.documentElement;
      const isLight = html.dataset.theme === 'light';
      if (isLight) {
        delete html.dataset.theme;
        localStorage.setItem('mal-theme', 'dark');
      } else {
        html.dataset.theme = 'light';
        localStorage.setItem('mal-theme', 'light');
      }
      // Re-render nav to update icon
      const nav = document.getElementById('app-nav');
      if (nav) {
        nav.innerHTML = renderNavigation();
        initNavigation();
      }
    });
  }
}
