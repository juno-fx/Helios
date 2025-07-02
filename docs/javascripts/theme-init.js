// Force dark mode on initial load
(function() {
  // Only set if no preference exists
  if (!localStorage.getItem('juno-theme')) {
    localStorage.setItem('juno-theme', 'slate');
    // Set attributes immediately
    if (document.documentElement) {
      document.documentElement.setAttribute('data-md-color-scheme', 'slate');
    }
    if (document.body) {
      document.body.setAttribute('data-md-color-scheme', 'slate');
    }
  } else {
    // Apply saved preference immediately
    const savedTheme = localStorage.getItem('juno-theme');
    if (document.documentElement) {
      document.documentElement.setAttribute('data-md-color-scheme', savedTheme);
    }
    if (document.body) {
      document.body.setAttribute('data-md-color-scheme', savedTheme);
    }
  }
})();