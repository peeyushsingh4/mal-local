import { listingRepository } from '../storage/ListingRepository.js';
import { getSeedListings } from '../data/seedData.js';
import { showToast } from './Toast.js';
import { icon } from './icons.js';

export async function renderSettings() {
  const isLight = document.documentElement.dataset.theme === 'light';
  const count = await listingRepository.count();

  return `
    <div class="page-container animate-in" style="padding-top: 84px;">
      <div class="page-header" style="background: var(--grad-hero); border: 1px solid rgba(247, 196, 19, 0.3); padding: 22px 24px; border-radius: var(--radius-md); margin-bottom: 24px;">
        <div style="display: inline-flex; align-items: center; gap: 6px; background: var(--blinkit-yellow); color: #0C831F; font-size: 0.75rem; font-weight: 900; padding: 4px 10px; border-radius: var(--radius-pill); text-transform: uppercase; margin-bottom: 8px;">
          ${icon('settings')} Preferences & Security
        </div>
        <h1 style="margin: 0 0 6px 0;">App Settings</h1>
        <p style="color:var(--text-muted); margin: 0;">Manage your theme preference, data export, and local data reset</p>
      </div>

      <!-- Appearance -->
      <h2 style="font-size:1.1rem;margin-bottom:12px">Appearance</h2>
      <div class="settings-section">
        <div class="settings-row">
          <div>
            <strong>Theme Preference</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">Switch between Blinkit Dark and Light modes</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" id="theme-switch" ${isLight ? 'checked' : ''} />
            <span class="toggle-slider"></span>
          </label>
        </div>
      </div>

      <!-- Data Management -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px">Data & Backup</h2>
      <div class="settings-section">
        <div class="settings-row">
          <div>
            <strong>Export Local Listings</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">${count} listings stored locally in IndexedDB</p>
          </div>
          <button class="btn btn-secondary" id="export-btn" style="display:inline-flex;align-items:center;gap:6px;">
            ${icon('download')} Export JSON
          </button>
        </div>
      </div>

      <!-- Security ADR Compliance -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px">Security & Privacy Posture</h2>
      <div class="settings-section" style="padding: 20px 24px;">
        <div style="display:flex;flex-direction:column;gap:12px;font-size:0.88rem;color:var(--text-muted);">
          <div style="display:flex;align-items:center;gap:8px;">
            ${icon('shieldCheck', 'var(--blinkit-green)')} <strong style="color:var(--text-main);">Zero Cloud Secrets:</strong> All AI operates on-device or via fallback templates.
          </div>
          <div style="display:flex;align-items:center;gap:8px;">
            ${icon('shieldCheck', 'var(--blinkit-green)')} <strong style="color:var(--text-main);">Data Minimization:</strong> Neighborhood areas stored ("Pali Hill"), never exact addresses.
          </div>
          <div style="display:flex;align-items:center;gap:8px;">
            ${icon('shieldCheck', 'var(--blinkit-green)')} <strong style="color:var(--text-main);">Zero Telemetry:</strong> No tracking scripts, pings, or analytics leave the device.
          </div>
          <div style="margin-top:6px;">
            <a href="docs/adr/0002-security-skeleton-stance.md" target="_blank" style="color:var(--blinkit-yellow);font-weight:700;text-decoration:none;">View Security ADR Document ➜</a>
          </div>
        </div>
      </div>

      <!-- Danger Zone -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px;color:var(--zomato-red)">Danger Zone</h2>
      <div class="settings-section danger-zone">
        <div class="settings-row">
          <div>
            <strong>Reset Local Data</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">Purge all local IndexedDB storage and restore default listings</p>
          </div>
          <button class="btn btn-danger" id="reset-btn" style="display:inline-flex;align-items:center;gap:6px;">
            ${icon('trash')} Reset Data
          </button>
        </div>
      </div>

      <!-- About -->
      <div style="margin-top:32px;text-align:center;color:var(--text-muted);font-size:0.85rem;">
        <div style="font-weight:800;color:var(--text-main);">MAL LOCAL v1.0.0</div>
        <div>Built for MAL Lab 1 Homework • Bandra West, Mumbai</div>
      </div>
    </div>

    <!-- Confirm Modal -->
    <div class="modal-overlay" id="confirm-modal">
      <div class="modal" role="dialog" aria-labelledby="modal-title" aria-modal="true">
        <h2 id="modal-title" style="display:flex;align-items:center;gap:8px;">${icon('trash', 'var(--zomato-red)')} Delete All Local Data?</h2>
        <p style="color:var(--text-muted);margin:16px 0">This will permanently delete all local listings from your browser IndexedDB and restore default Bandra West listings. This action cannot be undone.</p>
        <div style="display:flex;gap:12px;justify-content:flex-end">
          <button type="button" class="btn btn-ghost" id="modal-cancel">Cancel</button>
          <button type="button" class="btn btn-danger" id="modal-confirm">Delete Everything</button>
        </div>
      </div>
    </div>
  `;
}

export function initSettings() {
  const themeSwitch = document.getElementById('theme-switch');
  if (themeSwitch) {
    themeSwitch.addEventListener('change', (e) => {
      const html = document.documentElement;
      if (e.target.checked) {
        html.dataset.theme = 'light';
        localStorage.setItem('mal-theme', 'light');
      } else {
        delete html.dataset.theme;
        localStorage.setItem('mal-theme', 'dark');
      }
      const nav = document.getElementById('app-nav');
      if (nav) {
        import('./Navigation.js').then(module => {
          nav.innerHTML = module.renderNavigation();
          module.initNavigation();
        });
      }
    });
  }

  const exportBtn = document.getElementById('export-btn');
  if (exportBtn) {
    exportBtn.addEventListener('click', async () => {
      try {
        const listings = await listingRepository.getAll();
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(listings, null, 2));
        const downloadAnchor = document.createElement('a');
        downloadAnchor.setAttribute("href", dataStr);
        downloadAnchor.setAttribute("download", "mal-local-export.json");
        document.body.appendChild(downloadAnchor);
        downloadAnchor.click();
        downloadAnchor.remove();
        showToast('Listings exported successfully!', 'success');
      } catch (error) {
        showToast('Failed to export data', 'error');
      }
    });
  }

  const resetBtn = document.getElementById('reset-btn');
  const confirmModal = document.getElementById('confirm-modal');
  const modalCancel = document.getElementById('modal-cancel');
  const modalConfirm = document.getElementById('modal-confirm');

  if (resetBtn && confirmModal) {
    resetBtn.addEventListener('click', () => {
      confirmModal.classList.add('active');
    });

    const closeModal = () => {
      confirmModal.classList.remove('active');
    };

    if (modalCancel) modalCancel.addEventListener('click', closeModal);

    confirmModal.addEventListener('click', (e) => {
      if (e.target === confirmModal) closeModal();
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && confirmModal.classList.contains('active')) {
        closeModal();
      }
    });

    if (modalConfirm) {
      modalConfirm.addEventListener('click', async () => {
        try {
          await listingRepository.deleteAll();
          await listingRepository.seed(getSeedListings());
          showToast('Data reset successfully!', 'success');
          closeModal();
          router.navigate('/');
        } catch (error) {
          showToast('Failed to reset data', 'error');
          closeModal();
        }
      });
    }
  }
}
