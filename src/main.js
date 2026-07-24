/**
 * MAL Local — Main Application Entry Point
 * 
 * Wires together the router, components, storage, and AI service.
 * This is the single orchestration point for the entire SPA.
 */

import { router } from './router/Router.js';
import { listingRepository } from './storage/ListingRepository.js';
import { localAiService } from './ai/LocalAiService.js';
import { getSeedListings } from './data/seedData.js';

// Components
import { renderNavigation, initNavigation } from './components/Navigation.js';
import { renderListingFeed, initListingFeed } from './components/ListingFeed.js';
import { renderListingDetail, initListingDetail } from './components/ListingDetail.js';
import { renderCreateListingForm, initCreateListingForm } from './components/CreateListingForm.js';
import { renderNeighborhoodPulse, initNeighborhoodPulse } from './components/NeighborhoodPulse.js';
import { renderSettings, initSettings } from './components/Settings.js';

// DOM references
const navEl = document.getElementById('app-nav');
const rootEl = document.getElementById('app-root');

/**
 * Render the navigation bar and bind its events.
 * Called on every route change to update the active link.
 */
function updateNav() {
  if (navEl) {
    navEl.className = 'app-nav';
    navEl.innerHTML = renderNavigation();
    initNavigation();
  }
}

/**
 * Mount a page into the main content area.
 * Handles both sync and async render functions.
 * 
 * @param {Function} renderFn - Component render function (may be async)
 * @param {Function} [initFn] - Component init function for event bindings
 * @param  {...any} args - Arguments passed to render and init
 */
async function mountPage(renderFn, initFn, ...args) {
  // Update nav to reflect current route
  updateNav();

  // Scroll to top on navigation
  window.scrollTo(0, 0);

  // Show loading state
  rootEl.innerHTML = `
    <div class="page-container" style="display:flex;align-items:center;justify-content:center;min-height:60vh">
      <div style="text-align:center;color:var(--text-muted)">
        <div style="font-size:2rem;margin-bottom:8px" aria-hidden="true">⏳</div>
        <p>Loading...</p>
      </div>
    </div>
  `;

  try {
    // Render the page (may be async for data fetching)
    const html = await renderFn(...args);
    rootEl.innerHTML = html;

    // Bind event handlers after DOM is ready
    if (initFn) {
      initFn(...args);
    }
  } catch (error) {
    console.error('[MAL Local] Page render error:', error);
    rootEl.innerHTML = `
      <div class="page-container">
        <div class="empty-state">
          <div style="font-size:3rem" aria-hidden="true">😵</div>
          <h3>Something went wrong</h3>
          <p>${error.message || 'An unexpected error occurred.'}</p>
          <a href="#/" class="btn btn-primary">Back to Feed</a>
        </div>
      </div>
    `;
  }
}

/**
 * Configure all application routes.
 */
function setupRoutes() {
  router
    // Home / Feed
    .addRoute('/', () => {
      mountPage(renderListingFeed, initListingFeed);
    })
    // Create Listing
    .addRoute('/create', () => {
      mountPage(renderCreateListingForm, initCreateListingForm);
    })
    // Listing Detail
    .addRoute('/listing/:id', (params) => {
      mountPage(
        () => renderListingDetail(params.id),
        () => initListingDetail(params.id)
      );
    })
    // Neighborhood Pulse
    .addRoute('/pulse', () => {
      mountPage(renderNeighborhoodPulse, initNeighborhoodPulse);
    })
    // Settings
    .addRoute('/settings', () => {
      mountPage(renderSettings, initSettings);
    })
    // Fallback — redirect to feed
    .setFallback(() => {
      router.navigate('/');
    });
}

/**
 * Initialize the application.
 * Seeds data on first run and starts the router.
 */
async function initApp() {
  console.log('[MAL Local] Initializing...');

  try {
    // Seed data if empty (first run)
    const seedListings = getSeedListings();
    await listingRepository.seed(seedListings);
    console.log('[MAL Local] Data ready.');

    // Initialize AI service in the background (non-blocking)
    localAiService.initialize().then(() => {
      const status = localAiService.getStatus();
      console.log('[MAL Local] AI status:', status);
    });

    // Setup routes and start router
    setupRoutes();
    router.start();

    console.log('[MAL Local] App started successfully. 🚀');
  } catch (error) {
    console.error('[MAL Local] Initialization failed:', error);
    // Show error in the UI
    if (rootEl) {
      rootEl.innerHTML = `
        <div class="page-container">
          <div class="empty-state">
            <div style="font-size:3rem" aria-hidden="true">⚠️</div>
            <h3>Failed to start</h3>
            <p>Could not initialize the app. Please try refreshing the page.</p>
            <button class="btn btn-primary" onclick="location.reload()">Refresh</button>
          </div>
        </div>
      `;
    }
  }
}

// Start the app
initApp();
