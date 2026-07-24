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
        <a href="#/" class="brand-name" style="display: flex; align-items: center; gap: 8px;">
          <span style="background: var(--grad-primary); color: white; border-radius: 10px; padding: 4px 10px; font-weight: 900; font-size: 1rem; box-shadow: 0 4px 12px rgba(252, 128, 25, 0.4);">MAL</span>
          <span style="font-family: var(--font-display); font-weight: 800; font-size: 1.1rem; color: var(--text-main);">LOCAL</span>
        </a>

        <!-- Blinkit / Swiggy Location Bar -->
        <div class="location-pill" style="display: flex; align-items: center; gap: 6px; background: var(--bg-dark-elevated-2); border: 1px solid var(--glass-border); padding: 5px 12px; border-radius: var(--radius-pill); font-size: 0.8rem; font-weight: 600; cursor: pointer;">
          <span style="color: var(--swiggy-orange)">📍</span>
          <span style="color: var(--text-main)">Bandra West, Mumbai</span>
          <span style="color: var(--blinkit-green); font-size: 0.7rem; background: rgba(12, 131, 31, 0.15); padding: 2px 6px; border-radius: 4px; font-weight: 700;">⚡ LOCAL</span>
        </div>
      </div>

      <div class="nav-links">
        <a href="#/" class="nav-link ${currentHash === '/' ? 'active' : ''}">
          <span style="margin-right: 4px;">🏠</span> Feed
        </a>
        <a href="#/create" class="nav-link nav-btn-cta ${currentHash === '/create' ? 'active' : ''}">
          <span style="margin-right: 4px;">➕</span> Create Listing
        </a>
        <a href="#/pulse" class="nav-link ${currentHash === '/pulse' ? 'active' : ''}">
          <span style="margin-right: 4px;">📊</span> Pulse
        </a>
        <a href="#/settings" class="nav-link ${currentHash === '/settings' ? 'active' : ''}">
          <span style="margin-right: 4px;">⚙️</span> Settings
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
