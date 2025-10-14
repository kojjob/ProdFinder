import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auth-form"
export default class extends Controller {
  static targets = [
    "emailInput", "emailError", "emailErrorText", "emailValidIcon",
    "submitButton", "loadingMessage"
  ]

  connect() {
    this.emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  }

  validateEmail() {
    const email = this.emailInputTarget.value.trim()
    const isValid = this.emailRegex.test(email)
    
    this.clearEmailValidation()
    
    if (email.length === 0) {
      return // Don't show validation for empty field
    }
    
    if (isValid) {
      this.showEmailSuccess()
    } else {
      this.showEmailError("Please enter a valid email address")
    }
    
    this.updateSubmitButton()
  }

  showEmailError(message) {
    this.emailInputTarget.classList.add("form-input-error")
    this.emailInputTarget.classList.remove("form-input-success")
    this.emailErrorTarget.classList.remove("hidden")
    this.emailErrorTextTarget.textContent = message
    this.emailValidIconTarget.classList.add("hidden")
  }

  showEmailSuccess() {
    this.emailInputTarget.classList.remove("form-input-error")
    this.emailInputTarget.classList.add("form-input-success")
    this.emailErrorTarget.classList.add("hidden")
    this.emailValidIconTarget.classList.remove("hidden")
  }

  clearEmailValidation() {
    this.emailInputTarget.classList.remove("form-input-error", "form-input-success")
    this.emailErrorTarget.classList.add("hidden")
    this.emailValidIconTarget.classList.add("hidden")
  }

  updateSubmitButton() {
    const email = this.emailInputTarget.value.trim()
    const isEmailValid = this.emailRegex.test(email)
    
    if (isEmailValid) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  handleSubmit(event) {
    const email = this.emailInputTarget.value.trim()
    
    if (!this.emailRegex.test(email)) {
      event.preventDefault()
      this.showEmailError("Please enter a valid email address")
      return
    }

    // Show loading state
    this.showLoadingState()
  }

  showLoadingState() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.classList.add("btn-loading")
    this.loadingMessageTarget.classList.remove("hidden")
    
    // Hide loading state after form submission (in case of errors)
    setTimeout(() => {
      this.hideLoadingState()
    }, 5000)
  }

  hideLoadingState() {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.classList.remove("btn-loading")
    this.loadingMessageTarget.classList.add("hidden")
  }

  // Handle form errors from server
  showServerError(message) {
    this.hideLoadingState()
    this.showEmailError(message)
  }
}
