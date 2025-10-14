import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "content"]
  static values = {
    open: Boolean
  }

  connect() {
    // Add ESC key listener
    this.boundHandleEscape = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.boundHandleEscape)
    
    // Prevent body scroll when modal is open
    document.body.style.overflow = 'hidden'
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleEscape)
    document.body.style.overflow = ''
  }

  close() {
    this.element.remove()
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }

  // Prevent clicks inside the modal from closing it
  click(event) {
    event.stopPropagation()
  }
}