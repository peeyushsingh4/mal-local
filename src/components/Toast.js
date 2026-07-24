export function showToast(message, type = 'info') {
  let container = document.getElementById('toast-container');
  
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    container.setAttribute('aria-live', 'polite');
    
    // Add default styles if not already provided in CSS
    container.style.position = 'fixed';
    container.style.bottom = '1.5rem';
    container.style.right = '1.5rem';
    container.style.display = 'flex';
    container.style.flexDirection = 'column';
    container.style.gap = '0.5rem';
    container.style.zIndex = '9999';
    
    document.body.appendChild(container);
  }
  
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.setAttribute('role', 'alert');
  
  // Basic styles for toast in case CSS is missing
  toast.style.padding = '0.75rem 1.25rem';
  toast.style.borderRadius = '8px';
  toast.style.backgroundColor = 'var(--surface, #1e1e1e)';
  toast.style.color = 'var(--text, #fff)';
  toast.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
  toast.style.display = 'flex';
  toast.style.alignItems = 'center';
  toast.style.gap = '0.75rem';
  toast.style.opacity = '0';
  toast.style.transform = 'translateY(10px)';
  toast.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
  
  if (type === 'success') {
      toast.style.borderLeft = '4px solid #10b981';
  } else if (type === 'error') {
      toast.style.borderLeft = '4px solid #ef4444';
  } else {
      toast.style.borderLeft = '4px solid #3b82f6';
  }
  
  let icon = 'ℹ';
  if (type === 'success') icon = '✓';
  else if (type === 'error') icon = '✕';
  
  toast.innerHTML = `<span class="toast-icon" aria-hidden="true">${icon}</span> <span class="toast-message">${message}</span>`;
  
  container.appendChild(toast);
  
  // Trigger animation
  requestAnimationFrame(() => {
    toast.style.opacity = '1';
    toast.style.transform = 'translateY(0)';
  });
  
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(10px)';
    
    // Remove element after animation
    toast.addEventListener('transitionend', () => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast);
      }
    });
  }, 3000);
}
