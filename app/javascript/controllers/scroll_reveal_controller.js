import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-reveal"
// Reveals elements with Apple-inspired animations as they scroll into view
export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 0.1 },
    once: { type: Boolean, default: true }
  }

  connect() {
    // Set initial hidden state
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(30px)"
    this.element.style.transition = "opacity 0.6s cubic-bezier(0.16, 1, 0.3, 1), transform 0.6s cubic-bezier(0.16, 1, 0.3, 1)"

    // Create intersection observer
    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersection(entries),
      {
        threshold: this.thresholdValue,
        rootMargin: "0px 0px -50px 0px" // Trigger slightly before element is visible
      }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.reveal()

        // Optionally unobserve after first reveal
        if (this.onceValue) {
          this.observer.unobserve(this.element)
        }
      } else if (!this.onceValue) {
        this.hide()
      }
    })
  }

  reveal() {
    requestAnimationFrame(() => {
      this.element.style.opacity = "1"
      this.element.style.transform = "translateY(0)"
    })
  }

  hide() {
    requestAnimationFrame(() => {
      this.element.style.opacity = "0"
      this.element.style.transform = "translateY(30px)"
    })
  }
}
