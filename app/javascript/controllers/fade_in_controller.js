import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="fade-in"
// Provides Apple-inspired entrance animations for elements
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 0 },
    duration: { type: Number, default: 600 },
    distance: { type: Number, default: 20 }
  }

  connect() {
    // Set initial state
    this.element.style.opacity = "0"
    this.element.style.transform = `translateY(${this.distanceValue}px)`

    // Trigger animation after optional delay
    setTimeout(() => {
      this.animateIn()
    }, this.delayValue)
  }

  animateIn() {
    requestAnimationFrame(() => {
      this.element.style.transition = `opacity ${this.durationValue}ms cubic-bezier(0.16, 1, 0.3, 1), transform ${this.durationValue}ms cubic-bezier(0.16, 1, 0.3, 1)`
      this.element.style.opacity = "1"
      this.element.style.transform = "translateY(0)"
    })
  }
}
