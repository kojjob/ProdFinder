import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hover-effect"
// Adds Apple-inspired hover micro-interactions
export default class extends Controller {
  static values = {
    scale: { type: Number, default: 1.02 },
    translateY: { type: Number, default: -2 }
  }

  connect() {
    // Add transition for smooth hover effects
    this.element.style.transition = "all 0.3s cubic-bezier(0.16, 1, 0.3, 1)"

    // Store original transform for restoration
    this.originalTransform = this.element.style.transform || "none"
  }

  mouseenter() {
    // Apply subtle scale and lift on hover
    this.element.style.transform = `scale(${this.scaleValue}) translateY(${this.translateYValue}px)`
  }

  mouseleave() {
    // Return to original state
    this.element.style.transform = this.originalTransform
  }

  // Touch device support
  touchstart() {
    this.mouseenter()
  }

  touchend() {
    this.mouseleave()
  }
}
