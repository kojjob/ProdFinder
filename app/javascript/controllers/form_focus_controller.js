import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-focus"
// Adds Apple-inspired focus animations to form fields
export default class extends Controller {
  static targets = ["input", "label"]

  connect() {
    // Add transition to all inputs
    this.inputTargets.forEach(input => {
      input.style.transition = "all 0.3s cubic-bezier(0.16, 1, 0.3, 1)"
    })

    // Add transition to all labels
    this.labelTargets.forEach(label => {
      label.style.transition = "all 0.3s cubic-bezier(0.16, 1, 0.3, 1)"
    })
  }

  focus(event) {
    const input = event.currentTarget

    // Add smooth scale and glow effect on focus
    input.style.transform = "scale(1.01)"

    // Optionally animate associated label
    const label = this.labelTargets.find(l =>
      l.getAttribute('for') === input.id
    )
    if (label) {
      label.style.transform = "translateY(-2px)"
      label.style.color = "rgb(59, 130, 246)" // primary-500
    }
  }

  blur(event) {
    const input = event.currentTarget

    // Remove scale on blur
    input.style.transform = "scale(1)"

    // Reset label
    const label = this.labelTargets.find(l =>
      l.getAttribute('for') === input.id
    )
    if (label) {
      label.style.transform = "translateY(0)"
      label.style.color = "" // Reset to default
    }
  }

  // Smooth placeholder animation
  animatePlaceholder(event) {
    const input = event.currentTarget
    if (input.value.length === 0) {
      input.setAttribute('placeholder-visible', 'true')
    } else {
      input.setAttribute('placeholder-visible', 'false')
    }
  }
}
