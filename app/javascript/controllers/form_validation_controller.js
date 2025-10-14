import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "textarea", "submit", "charCount", "error"]
  static values = {
    maxLength: Number,
    minLength: Number,
    pattern: String,
    required: Boolean
  }

  connect() {
    this.validateAll()
  }

  validate() {
    this.validateField(this.currentTarget)
  }

  validateAll() {
    let isValid = true
    
    this.inputTargets.forEach(input => {
      if (!this.validateField(input)) {
        isValid = false
      }
    })

    this.textareaTargets.forEach(textarea => {
      if (!this.validateField(textarea)) {
        isValid = false
      }
    })

    this.toggleSubmitButton(isValid)
  }

  validateField(field) {
    const isValid = this.checkFieldValidity(field)
    this.showFieldError(field, isValid)
    this.updateCharCount(field)
    
    return isValid
  }

  checkFieldValidity(field) {
    const value = field.value.trim()
    
    // Required validation
    if (field.hasAttribute('required') && value.length === 0) {
      return false
    }

    // Min length validation
    const minLength = field.dataset.minLength || field.getAttribute('minlength')
    if (minLength && value.length < parseInt(minLength)) {
      return false
    }

    // Max length validation
    const maxLength = field.dataset.maxLength || field.getAttribute('maxlength')
    if (maxLength && value.length > parseInt(maxLength)) {
      return false
    }

    // Pattern validation
    const pattern = field.dataset.pattern || field.getAttribute('pattern')
    if (pattern && !new RegExp(pattern).test(value)) {
      return false
    }

    // Email validation
    if (field.type === 'email' && value.length > 0) {
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!emailPattern.test(value)) {
        return false
      }
    }

    // URL validation
    if (field.type === 'url' && value.length > 0) {
      try {
        new URL(value)
      } catch {
        return false
      }
    }

    return true
  }

  showFieldError(field, isValid) {
    const errorElement = field.parentNode.querySelector('.field-error')
    
    if (!isValid) {
      field.classList.add('border-red-500', 'focus:ring-red-500')
      field.classList.remove('border-gray-300', 'focus:ring-blue-500')
      
      if (errorElement) {
        errorElement.classList.remove('hidden')
      } else {
        this.createErrorElement(field)
      }
    } else {
      field.classList.remove('border-red-500', 'focus:ring-red-500')
      field.classList.add('border-gray-300', 'focus:ring-blue-500')
      
      if (errorElement) {
        errorElement.classList.add('hidden')
      }
    }
  }

  createErrorElement(field) {
    const error = document.createElement('div')
    error.className = 'field-error text-sm text-red-600 mt-1'
    error.textContent = this.getErrorMessage(field)
    
    field.parentNode.appendChild(error)
  }

  getErrorMessage(field) {
    const value = field.value.trim()
    const label = field.getAttribute('aria-label') || field.name.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase())
    
    if (field.hasAttribute('required') && value.length === 0) {
      return `${label} is required`
    }

    const minLength = field.dataset.minLength || field.getAttribute('minlength')
    if (minLength && value.length < parseInt(minLength)) {
      return `${label} must be at least ${minLength} characters`
    }

    const maxLength = field.dataset.maxLength || field.getAttribute('maxlength')
    if (maxLength && value.length > parseInt(maxLength)) {
      return `${label} must be less than ${maxLength} characters`
    }

    if (field.type === 'email' && value.length > 0) {
      return 'Please enter a valid email address'
    }

    if (field.type === 'url' && value.length > 0) {
      return 'Please enter a valid URL'
    }

    return `${label} is invalid`
  }

  updateCharCount(field) {
    if (field.type === 'textarea' && this.hasCharCountTarget) {
      const maxLength = field.getAttribute('maxlength')
      const currentLength = field.value.length
      
      this.charCountTarget.textContent = currentLength
      
      if (maxLength) {
        if (currentLength > parseInt(maxLength) * 0.9) {
          this.charCountTarget.classList.add('text-red-600')
          this.charCountTarget.classList.remove('text-gray-500')
        } else {
          this.charCountTarget.classList.remove('text-red-600')
          this.charCountTarget.classList.add('text-gray-500')
        }
      }
    }
  }

  toggleSubmitButton(isValid) {
    if (this.hasSubmitTarget) {
      if (isValid) {
        this.submitTarget.disabled = false
        this.submitTarget.classList.remove('opacity-50', 'cursor-not-allowed')
      } else {
        this.submitTarget.disabled = true
        this.submitTarget.classList.add('opacity-50', 'cursor-not-allowed')
      }
    }
  }

  // Real-time validation as user types
  input() {
    this.validate()
  }

  // Validate on blur
  blur() {
    this.validate()
  }
}