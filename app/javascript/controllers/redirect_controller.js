import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="redirect"
// Handles smooth redirects with Apple-inspired transitions
export default class extends Controller {
  static values = {
    url: String,
    delay: { type: Number, default: 2000 }
  }

  connect() {
    // Start redirect countdown
    this.timeout = setTimeout(() => {
      this.redirect()
    }, this.delayValue)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  redirect() {
    // Add smooth fade-out before redirect
    this.element.style.transition = "opacity 0.5s cubic-bezier(0.16, 1, 0.3, 1), transform 0.5s cubic-bezier(0.16, 1, 0.3, 1)"
    this.element.style.opacity = "0"
    this.element.style.transform = "scale(0.98)"

    setTimeout(() => {
      if (this.hasUrlValue) {
        window.location.href = this.urlValue
      }
    }, 500)
  }

  // Allow manual redirect trigger
  now() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.redirect()
  }
}
