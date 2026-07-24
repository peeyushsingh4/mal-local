import { listingRepository } from '../storage/ListingRepository.js';
import { showToast } from './Toast.js';
import { getSeedListings } from '../data/seedData.js';

export async function renderSettings() {
  const count = await listingRepository.count();
  const isLight = document.documentElement.getAttribute('data-theme') === 'light';
  
  return `
    <div class="page-container animate-in">
      <div class="page-header">
        <h1>Settings</h1>
        <p style="color:var(--text-muted)">Manage your preferences and data</p>
      </div>
      
      <!-- Appearance -->
      <h2 style="font-size:1.1rem;margin-bottom:12px">Appearance</h2>
      <div class="settings-section">
        <div class="settings-row">
          <div>
            <strong>Theme</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">Switch between dark and light mode</p>
          </div>
          <label class="toggle-switch">
            <input type="checkbox" id="theme-switch" ${isLight ? 'checked' : ''} />
            <span class="toggle-slider"></span>
          </label>
        </div>
      </div>
      
      <!-- Data -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px">Data Management</h2>
      <div class="settings-section">
        <div class="settings-row">
          <div>
            <strong>Export Data</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">${count} listings stored locally</p>
          </div>
          <button class="btn btn-secondary" id="export-btn">📥 Export JSON</button>
        </div>
      </div>
      
      <!-- Danger Zone -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px;color:var(--accent-coral)">Danger Zone</h2>
      <div class="settings-section danger-zone">
        <div class="settings-row">
          <div>
            <strong>Reset All Data</strong>
            <p style="color:var(--text-muted);font-size:0.875rem">Delete all listings and reset to default</p>
          </div>
          <button class="btn btn-danger" id="reset-btn">🗑 Reset Data</button>
        </div>
      </div>
      
      <!-- About -->
      <h2 style="font-size:1.1rem;margin:24px 0 12px">About</h2>
      <div class="settings-section">
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 8px;">
          <div><strong>App:</strong> MAL Local</div>
          <div><strong>Version:</strong> 1.0.0</div>
          <div><strong>Stack:</strong> Vite + Vanilla JS</div>
          <div><strong>Storage:</strong> IndexedDB (local-first)</div>
          <div><strong>AI:</strong> LocalAiService with deterministic fallback</div>
        </div>
      </div>
    </div>

    <!-- Confirm Modal -->
    <div class="modal-overlay" id="confirm-modal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:100; align-items:center; justify-content:center;">
      <div class="modal" role="dialog" aria-labelledby="modal-title" aria-modal="true" style="background:var(--bg-card, #2a2a2a); padding:24px; border-radius:var(--radius-lg); max-width:400px; width:90%;">
        <h2 id="modal-title">⚠️ Delete All Data</h2>
        <p style="color:var(--text-muted);margin:16px 0">This will permanently delete all listings and reset the app to default seed data. This action cannot be undone.</p>
        <div style="display:flex;gap:12px;justify-content:flex-end">
          <button class="btn btn-ghost" id="modal-cancel">Cancel</button>
          <button class="btn btn-danger" id="modal-confirm">Delete Everything</button>
        </div>
      </div>
    </div>
  `;
}

export function initSettings() {
  const themeSwitch = document.getElementById('theme-switch');
  if (themeSwitch) {
    themeSwitch.addEventListener('change', (e) => {
      const newTheme = e.target.checked ? 'light' : 'dark';
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);
    });
  }

  const exportBtn = document.getElementById('export-btn');
  if (exportBtn) {
    exportBtn.addEventListener('click', async () => {
      try {
        const listings = await listingRepository.getAll();
        const dataStr = JSON.stringify(listings, null, 2);
        const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
        
        const exportFileDefaultName = 'mal-local-export.json';
        
        const linkElement = document.createElement('a');
        linkElement.setAttribute('href', dataUri);
        linkElement.setAttribute('download', exportFileDefaultName);
        linkElement.click();
        
        showToast('Data exported successfully', 'success');
      } catch (err) {
        console.error(err);
        showToast('Failed to export data', 'error');
      }
    });
  }

  const resetBtn = document.getElementById('reset-btn');
  const modal = document.getElementById('confirm-modal');
  const cancelBtn = document.getElementById('modal-cancel');
  const confirmBtn = document.getElementById('modal-confirm');

  const closeModal = () => {
    modal.style.display = 'none';
  };

  if (resetBtn && modal) {
    resetBtn.addEventListener('click', () => {
      modal.style.display = 'flex';
      cancelBtn?.focus();
    });

    cancelBtn?.addEventListener('click', closeModal);
    
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeModal();
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal.style.display === 'flex') {
        closeModal();
      }
    });

    confirmBtn?.addEventListener('click', async () => {
      try {
        await listingRepository.deleteAll();
        await listingRepository.seed(getSeedListings());
        closeModal();
        showToast('All data has been reset', 'success');
        
        // Update the count display
        setTimeout(() => {
          location.reload();
        }, 1000);
      } catch (err) {
        console.error(err);
        showToast('Failed to reset data', 'error');
      }
    });
  }
}
