import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="card-hover"
// Adds premium hover effects to product cards
export default class extends Controller {
  static targets = ["card", "image", "content"]
  static values = {
    tiltAmount: { type: Number, default: 5 },
    scaleAmount: { type: Number, default: 1.02 }
  }

  connect() {
    console.log("Card hover controller connected")
    this.boundX = 0
    this.boundY = 0
  }

  // Mouse enter - start tracking
  mouseEnter(event) {
    if (this.hasCardTarget) {
      this.cardTarget.style.transition = 'transform 0.1s ease-out, box-shadow 0.3s ease'
    }
  }

  // Mouse move - apply tilt effect
  mouseMove(event) {
    if (!this.hasCardTarget) return

    const card = this.cardTarget
    const rect = card.getBoundingClientRect()
    
    // Calculate mouse position relative to card center
    const centerX = rect.left + rect.width / 2
    const centerY = rect.top + rect.height / 2
    const mouseX = event.clientX - centerX
    const mouseY = event.clientY - centerY
    
    // Calculate tilt angles
    const rotateX = (mouseY / (rect.height / 2)) * -this.tiltAmountValue
    const rotateY = (mouseX / (rect.width / 2)) * this.tiltAmountValue
    
    // Apply transform
    card.style.transform = `
      perspective(1000px)
      rotateX(${rotateX}deg)
      rotateY(${rotateY}deg)
      scale(${this.scaleAmountValue})
      translateZ(10px)
    `

    // Add glow effect based on mouse position
    const glowX = ((mouseX / rect.width) + 0.5) * 100
    const glowY = ((mouseY / rect.height) + 0.5) * 100
    
    card.style.setProperty('--glow-x', `${glowX}%`)
    card.style.setProperty('--glow-y', `${glowY}%`)
  }

  // Mouse leave - reset
  mouseLeave(event) {
    if (!this.hasCardTarget) return

    const card = this.cardTarget
    card.style.transition = 'transform 0.5s ease, box-shadow 0.3s ease'
    card.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) scale(1) translateZ(0px)'
  }

  // Click - add ripple effect
  click(event) {
    this.createRipple(event)
  }

  // Create ripple effect on click
  createRipple(event) {
    if (!this.hasCardTarget) return

    const card = this.cardTarget
    const rect = card.getBoundingClientRect()
    
    const ripple = document.createElement('div')
    const size = Math.max(rect.width, rect.height)
    const x = event.clientX - rect.left - size / 2
    const y = event.clientY - rect.top - size / 2
    
    ripple.style.cssText = `
      position: absolute;
      width: ${size}px;
      height: ${size}px;
      border-radius: 50%;
      background: radial-gradient(circle, rgba(220, 38, 38, 0.3) 0%, transparent 70%);
      top: ${y}px;
      left: ${x}px;
      pointer-events: none;
      animation: ripple-effect 0.6s ease-out;
      z-index: 0;
    `
    
    card.style.position = 'relative'
    card.style.overflow = 'hidden'
    card.appendChild(ripple)
    
    setTimeout(() => {
      ripple.remove()
    }, 600)
  }
}

