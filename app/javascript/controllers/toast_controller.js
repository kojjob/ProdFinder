import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
// Shows animated toast notifications
export default class extends Controller {
  static targets = ["container"]
  static values = {
    duration: { type: Number, default: 3000 },
    position: { type: String, default: "top-right" }
  }

  connect() {
    console.log("Toast controller connected")
    this.setupContainer()
  }

  // Setup toast container
  setupContainer() {
    if (!this.hasContainerTarget) {
      const container = document.createElement('div')
      container.id = 'toast-container'
      container.className = this.getContainerClasses()
      container.setAttribute('data-toast-target', 'container')
      document.body.appendChild(container)
    }
  }

  // Get container classes based on position
  getContainerClasses() {
    const baseClasses = 'fixed z-50 flex flex-col gap-3 pointer-events-none'
    const positions = {
      'top-right': 'top-4 right-4',
      'top-left': 'top-4 left-4',
      'top-center': 'top-4 left-1/2 transform -translate-x-1/2',
      'bottom-right': 'bottom-4 right-4',
      'bottom-left': 'bottom-4 left-4',
      'bottom-center': 'bottom-4 left-1/2 transform -translate-x-1/2'
    }
    
    return `${baseClasses} ${positions[this.positionValue] || positions['top-right']}`
  }

  // Show success toast
  success(message, options = {}) {
    this.show(message, 'success', options)
  }

  // Show error toast
  error(message, options = {}) {
    this.show(message, 'error', options)
  }

  // Show info toast
  info(message, options = {}) {
    this.show(message, 'info', options)
  }

  // Show warning toast
  warning(message, options = {}) {
    this.show(message, 'warning', options)
  }

  // Show toast notification
  show(message, type = 'info', options = {}) {
    const duration = options.duration || this.durationValue
    const toast = this.createToast(message, type, options)
    
    const container = document.getElementById('toast-container') || this.containerTarget
    container.appendChild(toast)
    
    // Trigger animation
    setTimeout(() => {
      toast.classList.add('toast-enter')
    }, 10)
    
    // Auto dismiss
    if (duration > 0) {
      setTimeout(() => {
        this.dismiss(toast)
      }, duration)
    }
  }

  // Create toast element
  createToast(message, type, options) {
    const toast = document.createElement('div')
    toast.className = `toast toast-${type} pointer-events-auto`
    
    const config = this.getToastConfig(type)
    
    toast.innerHTML = `
      <div class="flex items-start gap-3 p-4 rounded-xl shadow-lg backdrop-blur-sm border ${config.bgClass} ${config.borderClass} transform transition-all duration-300 ease-out translate-x-full opacity-0">
        <div class="flex-shrink-0">
          ${config.icon}
        </div>
        <div class="flex-1 min-w-0">
          ${options.title ? `<p class="font-bold ${config.textClass} mb-1">${options.title}</p>` : ''}
          <p class="${config.textClass} text-sm">${message}</p>
        </div>
        <button 
          type="button" 
          class="flex-shrink-0 ${config.textClass} hover:opacity-70 transition-opacity"
          onclick="this.closest('.toast').dispatchEvent(new CustomEvent('toast:dismiss', { bubbles: true }))"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>
    `
    
    // Add dismiss event listener
    toast.addEventListener('toast:dismiss', () => {
      this.dismiss(toast)
    })
    
    return toast
  }

  // Get toast configuration by type
  getToastConfig(type) {
    const configs = {
      success: {
        bgClass: 'bg-teal-50/90',
        borderClass: 'border-teal-200',
        textClass: 'text-teal-900',
        icon: `
          <svg class="w-6 h-6 text-teal-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
          </svg>
        `
      },
      error: {
        bgClass: 'bg-red-50/90',
        borderClass: 'border-red-200',
        textClass: 'text-red-900',
        icon: `
          <svg class="w-6 h-6 text-red-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
          </svg>
        `
      },
      warning: {
        bgClass: 'bg-amber-50/90',
        borderClass: 'border-amber-200',
        textClass: 'text-amber-900',
        icon: `
          <svg class="w-6 h-6 text-amber-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
          </svg>
        `
      },
      info: {
        bgClass: 'bg-blue-50/90',
        borderClass: 'border-blue-200',
        textClass: 'text-blue-900',
        icon: `
          <svg class="w-6 h-6 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
          </svg>
        `
      }
    }
    
    return configs[type] || configs.info
  }

  // Dismiss toast
  dismiss(toast) {
    const inner = toast.querySelector('div')
    if (inner) {
      inner.classList.remove('toast-enter')
      inner.classList.add('toast-exit')
      
      setTimeout(() => {
        toast.remove()
      }, 300)
    }
  }

  // Dismiss all toasts
  dismissAll() {
    const container = document.getElementById('toast-container')
    if (container) {
      const toasts = container.querySelectorAll('.toast')
      toasts.forEach(toast => this.dismiss(toast))
    }
  }
}

// Global toast helper
window.showToast = function(message, type = 'info', options = {}) {
  const event = new CustomEvent('toast:show', {
    detail: { message, type, options }
  })
  document.dispatchEvent(event)
}

// Listen for global toast events
document.addEventListener('toast:show', (event) => {
  const { message, type, options } = event.detail
  const controller = document.querySelector('[data-controller~="toast"]')
  
  if (controller && controller.toast) {
    controller.toast.show(message, type, options)
  } else {
    // Create temporary controller
    const temp = document.createElement('div')
    temp.setAttribute('data-controller', 'toast')
    document.body.appendChild(temp)
    
    setTimeout(() => {
      const toastController = window.Stimulus.getControllerForElementAndIdentifier(temp, 'toast')
      if (toastController) {
        toastController.show(message, type, options)
      }
    }, 10)
  }
})

