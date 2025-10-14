// Newsletter controller for footer subscription
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "button"]

  connect() {
    // Initialize any newsletter functionality
  }

  handleEnter(event) {
    if (event.key === 'Enter') {
      this.subscribe(event)
    }
  }

  subscribe(event) {
    event.preventDefault()
    
    const email = this.emailTarget.value
    
    if (!this.isValidEmail(email)) {
      this.showError('Please enter a valid email address')
      return
    }

    // Show loading state
    this.setLoadingState(true)
    
    // Simulate API call (replace with actual implementation)
    setTimeout(() => {
      this.setLoadingState(false)
      this.showSuccess('Successfully subscribed!')
      this.emailTarget.value = ''
    }, 1000)
  }

  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  setLoadingState(loading) {
    if (loading) {
      this.buttonTarget.disabled = true
      this.buttonTarget.textContent = 'Subscribing...'
      this.buttonTarget.classList.add('opacity-75', 'cursor-not-allowed')
    } else {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = 'Subscribe'
      this.buttonTarget.classList.remove('opacity-75', 'cursor-not-allowed')
    }
  }

  showSuccess(message) {
    this.showMessage(message, 'success')
  }

  showError(message) {
    this.showMessage(message, 'error')
  }

  showMessage(message, type) {
    // Create or update message element
    let messageEl = document.getElementById('newsletter-message')
    if (!messageEl) {
      messageEl = document.createElement('div')
      messageEl.id = 'newsletter-message'
      messageEl.className = 'mt-2 text-sm'
      this.emailTarget.parentNode.appendChild(messageEl)
    }

    messageEl.textContent = message
    messageEl.className = `mt-2 text-sm ${type === 'success' ? 'text-green-400' : 'text-red-400'}`

    // Auto-hide after 3 seconds
    setTimeout(() => {
      messageEl.textContent = ''
    }, 3000)
  }
}