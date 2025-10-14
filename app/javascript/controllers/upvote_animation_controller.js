import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upvote-animation"
export default class extends Controller {
  static targets = ["button", "count", "icon"]
  static values = {
    upvoted: Boolean
  }

  connect() {
    console.log("Upvote animation controller connected")
  }

  // Animate upvote with heart pulse effect
  animate(event) {
    // Prevent default if needed
    if (event) {
      // Don't prevent default - let Turbo handle the request
    }

    // Add pulse animation to icon
    if (this.hasIconTarget) {
      this.iconTarget.classList.add('animate-upvote-pulse')
      
      // Remove animation class after it completes
      setTimeout(() => {
        this.iconTarget.classList.remove('animate-upvote-pulse')
      }, 600)
    }

    // Add scale animation to button
    if (this.hasButtonTarget) {
      this.buttonTarget.classList.add('animate-upvote-scale')
      
      setTimeout(() => {
        this.buttonTarget.classList.remove('animate-upvote-scale')
      }, 300)
    }

    // Create floating +1 indicator
    this.createFloatingIndicator()

    // Add confetti effect for first upvote
    if (!this.upvotedValue) {
      this.createConfetti()
    }
  }

  // Create floating +1 indicator
  createFloatingIndicator() {
    if (!this.hasButtonTarget) return

    const indicator = document.createElement('div')
    indicator.textContent = '+1'
    indicator.className = 'absolute -top-8 left-1/2 transform -translate-x-1/2 text-red-600 font-bold text-lg pointer-events-none animate-float-up'
    
    this.buttonTarget.style.position = 'relative'
    this.buttonTarget.appendChild(indicator)

    // Remove after animation
    setTimeout(() => {
      indicator.remove()
    }, 1000)
  }

  // Create confetti particles
  createConfetti() {
    if (!this.hasButtonTarget) return

    const colors = ['#dc2626', '#2563eb', '#14b8a6', '#f59e0b']
    const particleCount = 12

    for (let i = 0; i < particleCount; i++) {
      const particle = document.createElement('div')
      particle.className = 'confetti-particle'
      particle.style.cssText = `
        position: absolute;
        width: 8px;
        height: 8px;
        background-color: ${colors[Math.floor(Math.random() * colors.length)]};
        border-radius: 50%;
        pointer-events: none;
        top: 50%;
        left: 50%;
        animation: confetti-burst 0.8s ease-out forwards;
        animation-delay: ${i * 0.02}s;
        --angle: ${(360 / particleCount) * i}deg;
      `
      
      this.buttonTarget.style.position = 'relative'
      this.buttonTarget.appendChild(particle)

      // Remove after animation
      setTimeout(() => {
        particle.remove()
      }, 1000)
    }
  }

  // Update count with animation
  updateCount(newCount) {
    if (!this.hasCountTarget) return

    const oldCount = parseInt(this.countTarget.textContent)
    const diff = newCount - oldCount

    if (diff !== 0) {
      // Animate count change
      this.countTarget.classList.add('animate-count-change')
      
      setTimeout(() => {
        this.countTarget.textContent = newCount
        this.countTarget.classList.remove('animate-count-change')
      }, 150)
    }
  }

  // Toggle upvoted state
  toggleUpvoted() {
    this.upvotedValue = !this.upvotedValue
  }
}

