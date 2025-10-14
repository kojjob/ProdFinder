// Mobile menu controller for responsive navigation
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close mobile menu when clicking outside
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    document.addEventListener('click', this.hideOnClickOutside)
    
    // Close mobile menu on escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.handleEscape)
  }

  disconnect() {
    document.removeEventListener('click', this.hideOnClickOutside)
    document.removeEventListener('keydown', this.handleEscape)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    this.menuTarget.classList.toggle('hidden')
  }

  hide() {
    this.menuTarget.classList.add('hidden')
  }

  show() {
    this.menuTarget.classList.remove('hidden')
  }

  hideOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.hide()
    }
  }
}