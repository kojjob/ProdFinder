// Dropdown controller for navbar menus
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Hide dropdown when clicking outside
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    document.addEventListener('click', this.hideOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.hideOnClickOutside)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // Close all other dropdowns
    document.querySelectorAll('[data-dropdown-target="menu"]').forEach(menu => {
      if (menu !== this.menuTarget) {
        menu.classList.add('opacity-0', 'invisible')
        menu.classList.remove('opacity-100', 'visible')
      }
    })

    // Toggle current dropdown
    this.menuTarget.classList.toggle('opacity-0')
    this.menuTarget.classList.toggle('invisible')
    this.menuTarget.classList.toggle('opacity-100')
    this.menuTarget.classList.toggle('visible')
  }

  hide() {
    this.menuTarget.classList.add('opacity-0', 'invisible')
    this.menuTarget.classList.remove('opacity-100', 'visible')
  }

  hideOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }
}