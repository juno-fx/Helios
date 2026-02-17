/* Juno Innovations Unified Documentation Theme JavaScript
   ======================================================= */

document.addEventListener('DOMContentLoaded', function() {
  console.log('Juno theme script loaded');

  // Initialize theme handling
  initializeTheme();

  // Initialize logo switching
  initializeLogoSwitching();

  // Initialize auto theme images
  initializeAutoThemeImages();

  // Initialize smooth scrolling
  initializeSmoothScrolling();

  // Initialize related documentation links
  initializeRelatedDocs();
});

/**
 * Theme Initialization and Management
 */
function initializeTheme() {
  // Check current theme
  const currentTheme = document.body.getAttribute('data-md-color-scheme');
  console.log('Current theme on load:', currentTheme);

  // Update logos immediately
  if (currentTheme) {
    updateLogos(currentTheme);
  }

  // Watch for theme changes
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.attributeName === 'data-md-color-scheme') {
        const newTheme = document.body.getAttribute('data-md-color-scheme');
        console.log('Theme changed to:', newTheme);
        if (newTheme) {
          // Add transition class
          document.body.classList.add('md-color-scheme-transition');

          // Update logos
          updateLogos(newTheme);

          // Remove transition class after animation completes
          setTimeout(() => {
            document.body.classList.remove('md-color-scheme-transition');
          }, 300);
        }
      }
    });
  });

  observer.observe(document.body, {
    attributes: true,
    attributeFilter: ['data-md-color-scheme']
  });

  // Listen for theme toggle clicks to prepare transition
  document.addEventListener('click', function(e) {
    const button = e.target.closest('[data-md-component="palette"] button');
    if (button) {
      // Add transition class immediately on click
      document.body.classList.add('md-color-scheme-transition');
    }
  });
}

/**
 * Logo Switching Based on Theme
 */
function initializeLogoSwitching() {
  const currentTheme = document.body.getAttribute('data-md-color-scheme') || 'slate';

  // Multiple attempts to ensure logos are loaded
  updateLogos(currentTheme);

  // Try again after images might have loaded
  if (document.readyState === 'loading') {
    document.addEventListener('readystatechange', function() {
      if (document.readyState === 'interactive' || document.readyState === 'complete') {
        updateLogos(currentTheme);
      }
    });
  }

  // Also try on window load
  window.addEventListener('load', function() {
    updateLogos(currentTheme);
  });
}

function updateLogos(theme) {
  const isDark = theme === 'slate';

  // Get all theme-aware logos (including header logos)
  const logos = document.querySelectorAll('.md-logo img, .md-header__button.md-logo img, img[data-theme-img], .theme-aware-image img');

  logos.forEach(logo => {
    const src = logo.getAttribute('src');
    if (!src) return;

    // Handle logos with existing -light/-dark suffix
    if (isDark && src.includes('-light')) {
      logo.src = src.replace('-light', '-dark');
    } else if (!isDark && src.includes('-dark')) {
      logo.src = src.replace('-dark', '-light');
    }
  });

  // Update data-theme-img images
  const themeImages = document.querySelectorAll('img[data-theme-img]');
  themeImages.forEach(img => {
    const baseName = img.getAttribute('data-theme-img');
    updateThemeImage(img, baseName, theme);
  });
}

/**
 * Smooth Scrolling for Anchor Links
 */
function initializeSmoothScrolling() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const href = this.getAttribute('href');
      if (href && href !== '#') {
        const target = document.querySelector(href);
        if (target) {
          e.preventDefault();
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });

          // Update URL without jumping
          history.pushState(null, null, href);
        }
      }
    });
  });
}

/**
 * Related Documentation Enhancement
 */
function initializeRelatedDocs() {
  // Add icons to related documentation links
  const relatedLinks = document.querySelectorAll('.related-docs a');
  relatedLinks.forEach(link => {
    if (!link.querySelector('.md-icon')) {
      const icon = document.createElement('span');
      icon.className = 'md-icon';
      icon.innerHTML = '→';
      link.appendChild(icon);
    }
  });
}

/**
 * Auto Theme Images Helper
 */
function initializeAutoThemeImages() {
  // Find all images with data-theme-img attribute
  const themeImages = document.querySelectorAll('img[data-theme-img]');

  themeImages.forEach(img => {
    const baseName = img.getAttribute('data-theme-img');
    const currentTheme = document.body.getAttribute('data-md-color-scheme');
    updateThemeImage(img, baseName, currentTheme);
  });
}

function updateThemeImage(img, baseName, theme) {
  const isDark = theme === 'slate';
  const suffix = isDark ? '-dark' : '-light';

  // Set the themed image path
  img.src = `/assets/logos/${baseName}/${baseName}${suffix}.png`;
}

/**
 * Utility Functions
 */

// Debounce function for performance
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Handle window resize events
window.addEventListener('resize', debounce(function() {
  // Re-initialize any responsive features if needed
}, 250));

// Export functions for use in other scripts if needed
window.JunoTheme = {
  updateLogos: updateLogos,
  initializeTheme: initializeTheme
};