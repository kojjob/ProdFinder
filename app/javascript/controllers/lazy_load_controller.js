import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "placeholder", "trigger"]
  static values = {
    url: String,
    loaded: Boolean,
    threshold: { type: Number, default: 0.1 }
  }

  connect() {
    this.setupIntersectionObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: '50px',
      threshold: this.thresholdValue
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.loadedValue) {
          this.loadContent()
        }
      })
    }, options)

    // Start observing the trigger element
    if (this.hasTriggerTarget) {
      this.observer.observe(this.triggerTarget)
    } else {
      // If no trigger target, observe the element itself
      this.observer.observe(this.element)
    }
  }

  async loadContent() {
    if (this.loadedValue) return

    this.loadedValue = true

    try {
      // Show loading state
      this.showLoading()

      // Fetch the content
      const response = await fetch(this.urlValue, {
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        credentials: 'same-origin'
      })

      if (response.ok) {
        const html = await response.text()
        
        // Replace placeholder with content
        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.remove()
        }

        if (this.hasContentTarget) {
          this.contentTarget.innerHTML = html
          this.contentTarget.classList.remove('hidden')
        }

        // Dispatch custom event for other controllers
        this.dispatch('loaded', { detail: { url: this.urlValue } })
      } else {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }
    } catch (error) {
      console.error('Lazy loading failed:', error)
      this.showError()
    } finally {
      this.hideLoading()
    }
  }

  showLoading() {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.innerHTML = this.getLoadingHTML()
    }
  }

  hideLoading() {
    // Remove loading state
    const loadingElements = this.element.querySelectorAll('.lazy-loading')
    loadingElements.forEach(el => el.remove())
  }

  showError() {
    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.innerHTML = this.getErrorHTML()
    }
  }

  getLoadingHTML() {
    return `
      <div class="lazy-loading flex items-center justify-center p-8">
        <div class="text-center">
          <div class="inline-flex items-center space-x-2">
            <svg class="animate-spin h-5 w-5 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span class="text-gray-600">Loading...</span>
          </div>
        </div>
      </div>
    `
  }

  getErrorHTML() {
    return `
      <div class="flex items-center justify-center p-8">
        <div class="text-center">
          <svg class="w-12 h-12 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
          <p class="text-gray-600">Failed to load content</p>
          <button 
            data-action="click->lazy-load#loadContent" 
            class="mt-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200">
            Retry
          </button>
        </div>
      </div>
    `
  }

  // Manual trigger for loading
  load() {
    this.loadContent()
  }
}