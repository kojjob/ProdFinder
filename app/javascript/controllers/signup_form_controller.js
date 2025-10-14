import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="signup-form"
// Enhanced with Apple-inspired micro-interactions and smooth animations
export default class extends Controller {
  static targets = [
    "emailInput", "emailError", "emailErrorText", "emailValidIcon",
    "usernameInput", "usernameError", "usernameErrorText", "usernameValidIcon",
    "nameInput", "nameError", "nameErrorText", "nameValidIcon",
    "submitButton", "loadingMessage", "successState", "emailDisplay",
    "form", "formFields"
  ]

  connect() {
    this.emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    this.usernameRegex = /^[a-zA-Z0-9_]{3,30}$/
    this.nameRegex = /^[a-zA-Z\s]{2,50}$/
    this.submittedEmail = null
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

    if (!this.usernameRegex.test(username)) {
      this.showUsernameError("Username must be 3-30 characters, letters, numbers, and underscores only")
    } else {
      this.showUsernameSuccess()
    }

    this.updateSubmitButton()
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
      this.showNameError("Full name must be 2-50 characters")
    }

    this.updateSubmitButton()
  }

  showEmailError(message) {
    this.emailInputTarget.classList.add("form-input-error")
    this.emailInputTarget.classList.remove("form-input-success")
    this.emailErrorTarget.classList.remove("hidden")
    this.emailErrorTextTarget.textContent = message

    // Hide validation icon with smooth animation
    this.emailValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.emailValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  showEmailSuccess() {
    this.emailInputTarget.classList.remove("form-input-error")
    this.emailInputTarget.classList.add("form-input-success")
    this.emailErrorTarget.classList.add("hidden")

    // Show validation icon with smooth scale and fade animation
    this.emailValidIconTarget.classList.remove("opacity-0", "scale-0")
    this.emailValidIconTarget.classList.add("opacity-100", "scale-100")
  }

  clearEmailValidation() {
    this.emailInputTarget.classList.remove("form-input-error", "form-input-success")
    this.emailErrorTarget.classList.add("hidden")

    // Hide validation icon
    this.emailValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.emailValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  showUsernameError(message) {
    this.usernameInputTarget.classList.add("form-input-error")
    this.usernameInputTarget.classList.remove("form-input-success")
    this.usernameErrorTarget.classList.remove("hidden")
    this.usernameErrorTextTarget.textContent = message

    // Hide validation icon with smooth animation
    this.usernameValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.usernameValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  showUsernameSuccess() {
    this.usernameInputTarget.classList.remove("form-input-error")
    this.usernameInputTarget.classList.add("form-input-success")
    this.usernameErrorTarget.classList.add("hidden")

    // Show validation icon with smooth scale and fade animation
    this.usernameValidIconTarget.classList.remove("opacity-0", "scale-0")
    this.usernameValidIconTarget.classList.add("opacity-100", "scale-100")
  }

  clearUsernameValidation() {
    this.usernameInputTarget.classList.remove("form-input-error", "form-input-success")
    this.usernameErrorTarget.classList.add("hidden")

    // Hide validation icon
    this.usernameValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.usernameValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  showNameError(message) {
    this.nameInputTarget.classList.add("form-input-error")
    this.nameInputTarget.classList.remove("form-input-success")
    this.nameErrorTarget.classList.remove("hidden")
    this.nameErrorTextTarget.textContent = message

    // Hide validation icon with smooth animation
    this.nameValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.nameValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  showNameSuccess() {
    this.nameInputTarget.classList.remove("form-input-error")
    this.nameInputTarget.classList.add("form-input-success")
    this.nameErrorTarget.classList.add("hidden")

    // Show validation icon with smooth scale and fade animation
    this.nameValidIconTarget.classList.remove("opacity-0", "scale-0")
    this.nameValidIconTarget.classList.add("opacity-100", "scale-100")
  }

  clearNameValidation() {
    this.nameInputTarget.classList.remove("form-input-error", "form-input-success")
    this.nameErrorTarget.classList.add("hidden")

    // Hide validation icon
    this.nameValidIconTarget.classList.remove("opacity-100", "scale-100")
    this.nameValidIconTarget.classList.add("opacity-0", "scale-0")
  }

  updateSubmitButton() {
    const email = this.emailInputTarget.value.trim()
    const username = this.usernameInputTarget.value.trim()
    const fullName = this.nameInputTarget.value.trim()

    const isEmailValid = this.emailRegex.test(email)
    const isUsernameValid = this.usernameRegex.test(username)
    const isNameValid = this.nameRegex.test(fullName)

    if (isEmailValid && isUsernameValid && isNameValid) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
    }
  }

  handleSubmit(event) {
    const email = this.emailInputTarget.value.trim()
    const username = this.usernameInputTarget.value.trim()
    const fullName = this.nameInputTarget.value.trim()

    const isEmailValid = this.emailRegex.test(email)
    const isUsernameValid = this.usernameRegex.test(username)
    const isNameValid = this.nameRegex.test(fullName)

    if (!isEmailValid || !isUsernameValid || !isNameValid) {
      event.preventDefault()
      this.validateEmail()
      this.validateUsername()
      this.validateName()
      return
    }

    // Store email for success state
    this.submittedEmail = email

    // Show loading state
    this.showLoadingState()

    // Simulate success state after form submission
    // In production, this would be triggered by a successful server response
    // For now, we'll show it after a delay for demo purposes
    setTimeout(() => {
      this.showSuccessState()
    }, 2000)
  }

  showLoadingState() {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.classList.add("btn-loading")
    this.loadingMessageTarget.classList.remove("hidden")

    // Add fade-out animation to form fields
    this.formFieldsTargets.forEach(field => {
      field.style.transition = "opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1)"
      field.style.opacity = "0.5"
    })
  }

  hideLoadingState() {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.classList.remove("btn-loading")
    this.loadingMessageTarget.classList.add("hidden")

    // Restore form fields opacity
    this.formFieldsTargets.forEach(field => {
      field.style.opacity = "1"
    })
  }

  showSuccessState() {
    // Hide loading state
    this.hideLoadingState()

    // Update email display in success message
    if (this.hasEmailDisplayTarget) {
      this.emailDisplayTarget.textContent = this.submittedEmail
    }

    // Hide form with smooth fade-out
    if (this.hasFormTarget) {
      this.formTarget.style.transition = "opacity 0.4s cubic-bezier(0.16, 1, 0.3, 1), transform 0.4s cubic-bezier(0.16, 1, 0.3, 1)"
      this.formTarget.style.opacity = "0"
      this.formTarget.style.transform = "translateY(-20px)"

      setTimeout(() => {
        this.formTarget.classList.add("hidden")

        // Show success state with smooth fade-in and scale animation
        if (this.hasSuccessStateTarget) {
          this.successStateTarget.classList.remove("hidden")
          this.successStateTarget.style.opacity = "0"
          this.successStateTarget.style.transform = "scale(0.95)"

          // Trigger animation with a small delay for smooth transition
          requestAnimationFrame(() => {
            this.successStateTarget.style.transition = "opacity 0.5s cubic-bezier(0.16, 1, 0.3, 1), transform 0.5s cubic-bezier(0.16, 1, 0.3, 1)"
            this.successStateTarget.style.opacity = "1"
            this.successStateTarget.style.transform = "scale(1)"
          })
        }
      }, 400)
    }
  }

  // Handle form errors from server
  showServerError(message) {
    this.hideLoadingState()
    this.showEmailError(message)
  }
}
