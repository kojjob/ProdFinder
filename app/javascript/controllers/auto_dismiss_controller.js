import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-dismiss"
// Enhanced with Apple-inspired micro-interactions and smooth animations
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    // Add entrance animation with Apple's cubic-bezier easing
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-20px) scale(0.95)"

    requestAnimationFrame(() => {
      this.element.style.transition = "opacity 0.4s cubic-bezier(0.16, 1, 0.3, 1), transform 0.4s cubic-bezier(0.16, 1, 0.3, 1)"
      this.element.style.opacity = "1"
      this.element.style.transform = "translateY(0) scale(1)"
    })

    this.timeout = setTimeout(() => {
      this.dismiss()
    }, this.delayValue || 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Apple-inspired exit animation with smooth fade and slide
    this.element.style.transition = "opacity 0.4s cubic-bezier(0.16, 1, 0.3, 1), transform 0.4s cubic-bezier(0.16, 1, 0.3, 1)"
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(-20px) scale(0.95)"

    setTimeout(() => {
      if (this.element.parentNode) {
        this.element.parentNode.removeChild(this.element)
      }
    }, 400)
  }

  // Manual dismiss (can be called from click events)
  close() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.dismiss()
  }
}
