import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dark-mode"
// Handles dark mode toggle with localStorage persistence and system preference detection
export default class extends Controller {
  static targets = ["toggle", "icon"]

  connect() {
    // Initialize dark mode based on saved preference or system preference
    this.initializeDarkMode()

    // Listen for system preference changes
    this.mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    this.mediaQuery.addEventListener('change', (e) => {
      if (!this.hasSavedPreference()) {
        this.applyDarkMode(e.matches)
      }
    })
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener('change', this.handleSystemChange)
    }
  }

  // Initialize dark mode on page load
  initializeDarkMode() {
    const savedTheme = localStorage.getItem('theme')

    if (savedTheme === 'dark') {
      this.applyDarkMode(true)
    } else if (savedTheme === 'light') {
      this.applyDarkMode(false)
    } else {
      // No saved preference, use system preference
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      this.applyDarkMode(prefersDark)
    }
  }

  // Toggle dark mode on/off
  toggle() {
    const isDark = document.documentElement.classList.contains('dark')
    this.applyDarkMode(!isDark)

    // Save preference
    localStorage.setItem('theme', !isDark ? 'dark' : 'light')
  }

  // Apply dark mode with smooth transition
  applyDarkMode(isDark) {
    // Add transition class for smooth color changes
    document.documentElement.classList.add('transition-colors', 'duration-300')

    if (isDark) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }

    // Update toggle button icon if present
    this.updateToggleIcon(isDark)

    // Remove transition class after animation completes
    setTimeout(() => {
      document.documentElement.classList.remove('transition-colors', 'duration-300')
    }, 300)
  }

  // Update toggle button icon based on current mode
  updateToggleIcon(isDark) {
    if (this.hasToggleTarget) {
      const icon = this.toggleTarget.querySelector('[data-dark-mode-target="icon"]')
      if (icon) {
        // Update icon (sun for light mode, moon for dark mode)
        if (isDark) {
          icon.innerHTML = `
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"></path>
            </svg>
          `
        } else {
          icon.innerHTML = `
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"></path>
            </svg>
          `
        }
      }
    }
  }

  // Check if user has saved a preference
  hasSavedPreference() {
    return localStorage.getItem('theme') !== null
  }

  // Get current theme
  getCurrentTheme() {
    return document.documentElement.classList.contains('dark') ? 'dark' : 'light'
  }
}
