/**
 * A simple hash-based SPA Router
 */
export default class Router {
  constructor() {
    this.routes = [];
    this.fallback = null;
  }

  /**
   * Add a route with a path pattern and a handler
   * @param {string} path - e.g., '/' or '/listing/:id'
   * @param {Function} handler - Function called when route matches
   */
  addRoute(path, handler) {
    // Convert path pattern to regex, e.g. /listing/:id -> /listing/([^/]+)
    const paramNames = [];
    const regexPath = path.replace(/:([^\s/]+)/g, (_, paramName) => {
      paramNames.push(paramName);
      return '([^/]+)';
    });
    
    this.routes.push({
      pattern: new RegExp(`^${regexPath}$`),
      paramNames,
      handler
    });
    return this;
  }

  /**
   * Set a fallback route if no pattern matches
   */
  setFallback(handler) {
    this.fallback = handler;
    return this;
  }

  /**
   * Programmatically navigate to a path
   */
  navigate(path) {
    window.location.hash = path;
  }

  /**
   * Start listening for hash changes and process current route
   */
  start() {
    window.addEventListener('hashchange', () => this.handleRoute());
    // Handle initial route, fallback to '/' if no hash
    if (!window.location.hash) {
      window.location.hash = '/';
    } else {
      this.handleRoute();
    }
  }

  /**
   * Process the current hash against registered routes
   */
  handleRoute() {
    const path = window.location.hash.slice(1) || '/';
    let matchFound = false;

    for (const route of this.routes) {
      const match = path.match(route.pattern);
      if (match) {
        matchFound = true;
        const params = {};
        // Extract params
        route.paramNames.forEach((name, i) => {
          params[name] = match[i + 1];
        });
        route.handler(params);
        break;
      }
    }

    if (!matchFound && this.fallback) {
      this.fallback();
    }
  }
}

// Export singleton instance
export const router = new Router();
