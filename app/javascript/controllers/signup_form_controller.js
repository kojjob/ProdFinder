import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="signup-form"
export default class extends Controller {
  static targets = [
    "emailInput", "emailError", "emailErrorText", "emailValidIcon", "emailSuccess",
    "usernameInput", "usernameError", "usernameErrorText", "usernameValidIcon", "usernameSuccess",
    "nameInput", "nameError", "nameErrorText", "nameValidIcon",
    "submitButton", "loadingMessage"
  ]

  connect() {
    this.emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    this.usernameRegex = /^[a-zA-Z0-9_]{3,30}$/
    this.nameRegex = /^.{2,100}$/
    
    // Debounce username validation to avoid too many API calls
    this.usernameValidationTimeout = null
    
    // Track username availability state
    this.usernameAvailable = null
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

  validateUsername() {
    const username = this.usernameInputTarget.value.trim()
    
    this.clearUsernameValidation()
    
    if (username.length === 0) {
      return // Don't show validation for empty field
    }
    
    // Clear previous timeout
    if (this.usernameValidationTimeout) {
      clearTimeout(this.usernameValidationTimeout)
    }
    
    // Basic format validation
    if (!this.usernameRegex.test(username)) {
      this.showUsernameError("Username must be 3-30 characters, letters, numbers, and underscores only")
      this.updateSubmitButton()
      return
    }
    
    // Set username availability to false before API call
    this.usernameAvailable = false
    
    // Debounced availability check
    this.usernameValidationTimeout = setTimeout(() => {
      this.checkUsernameAvailability(username)
    }, 500)
  }

  validateName() {
    const name = this.nameInputTarget.value.trim()
    
    this.clearNameValidation()
    
    if (name.length === 0) {
      return // Don't show validation for empty field
    }
    
    if (this.nameRegex.test(name)) {
      this.showNameSuccess()
    } else {
      this.showNameError("Name must be 2-100 characters long")
    }
    
    this.updateSubmitButton()
  }

  async checkUsernameAvailability(username) {
    try {
      // In a real app, you'd make an API call here
      // For now, we'll simulate some basic validation
      const unavailableUsernames = ['admin', 'root', 'user', 'test', 'demo']
      
      if (unavailableUsernames.includes(username.toLowerCase())) {
        this.usernameAvailable = false
        this.showUsernameError("This username is not available")
      } else {
        this.usernameAvailable = true
        this.showUsernameSuccess()
      }
    } catch (error) {
      console.error('Username validation error:', error)
      this.usernameAvailable = false
      // Don't show error to user for API failures
    }
    
    this.updateSubmitButton()
  }

  // Email validation methods
  showEmailError(message) {
    this.emailInputTarget.classList.add("form-input-error")
    this.emailInputTarget.classList.remove("form-input-success")
    this.emailErrorTarget.classList.remove("hidden")
    this.emailSuccessTarget.classList.add("hidden")
    this.emailErrorTextTarget.textContent = message
    this.emailValidIconTarget.classList.add("hidden")
  }

  showEmailSuccess() {
    this.emailInputTarget.classList.remove("form-input-error")
    this.emailInputTarget.classList.add("form-input-success")
    this.emailErrorTarget.classList.add("hidden")
    this.emailSuccessTarget.classList.remove("hidden")
    this.emailValidIconTarget.classList.remove("hidden")
  }

  clearEmailValidation() {
    this.emailInputTarget.classList.remove("form-input-error", "form-input-success")
    this.emailErrorTarget.classList.add("hidden")
    this.emailSuccessTarget.classList.add("hidden")
    this.emailValidIconTarget.classList.add("hidden")
  }

  // Username validation methods
  showUsernameError(message) {
    this.usernameInputTarget.classList.add("form-input-error")
    this.usernameInputTarget.classList.remove("form-input-success")
    this.usernameErrorTarget.classList.remove("hidden")
    this.usernameSuccessTarget.classList.add("hidden")
    this.usernameErrorTextTarget.textContent = message
    this.usernameValidIconTarget.classList.add("hidden")
  }

  showUsernameSuccess() {
    this.usernameInputTarget.classList.remove("form-input-error")
    this.usernameInputTarget.classList.add("form-input-success")
    this.usernameErrorTarget.classList.add("hidden")
    this.usernameSuccessTarget.classList.remove("hidden")
    this.usernameValidIconTarget.classList.remove("hidden")
  }

  clearUsernameValidation() {
    this.usernameInputTarget.classList.remove("form-input-error", "form-input-success")
    this.usernameErrorTarget.classList.add("hidden")
    this.usernameSuccessTarget.classList.add("hidden")
    this.usernameValidIconTarget.classList.add("hidden")
    // Reset username availability when clearing validation
    this.usernameAvailable = null
  }

  // Name validation methods
  showNameError(message) {
    this.nameInputTarget.classList.add("form-input-error")
    this.nameInputTarget.classList.remove("form-input-success")
    this.nameErrorTarget.classList.remove("hidden")
    this.nameErrorTextTarget.textContent = message
    this.nameValidIconTarget.classList.add("hidden")
  }

  showNameSuccess() {
    this.nameInputTarget.classList.remove("form-input-error")
    this.nameInputTarget.classList.add("form-input-success")
    this.nameErrorTarget.classList.add("hidden")
    this.nameValidIconTarget.classList.remove("hidden")
  }

  clearNameValidation() {
    this.nameInputTarget.classList.remove("form-input-error", "form-input-success")
    this.nameErrorTarget.classList.add("hidden")
    this.nameValidIconTarget.classList.add("hidden")
  }

  updateSubmitButton() {
    const email = this.emailInputTarget.value.trim()
    const username = this.usernameInputTarget.value.trim()
    const fullName = this.nameInputTarget.value.trim()

    const isEmailValid = this.emailRegex.test(email)
    const isUsernameValid = this.usernameRegex.test(username)
    const isNameValid = this.nameRegex.test(fullName)

    // Require username availability in addition to regex validity
    const allValid = isEmailValid && isUsernameValid && isNameValid && this.usernameAvailable === true

    if (allValid) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  handleSubmit(event) {
    // Validate all fields before submission
    this.validateEmail()
    this.validateUsername()
    this.validateName()

    const email = this.emailInputTarget.value.trim()
    const username = this.usernameInputTarget.value.trim()
    const fullName = this.nameInputTarget.value.trim()

    const isEmailValid = this.emailRegex.test(email)
    const isUsernameValid = this.usernameRegex.test(username)
    const isNameValid = this.nameRegex.test(fullName)

    if (!isEmailValid || !isUsernameValid || !isNameValid) {
      event.preventDefault()
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
    }, 10000)
  }

  hideLoadingState() {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.classList.remove("btn-loading")
    this.loadingMessageTarget.classList.add("hidden")
  }

  disconnect() {
    // Clean up timeout to avoid memory leaks
    if (this.usernameValidationTimeout) {
      clearTimeout(this.usernameValidationTimeout)
      this.usernameValidationTimeout = null
    }
  }
}
