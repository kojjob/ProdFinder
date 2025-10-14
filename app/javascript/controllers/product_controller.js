import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo"

export default class extends Controller {
  static targets = ["upvoteButton", "upvoteCount", "commentForm", "commentsList"]
  static values = {
    productId: String,
    upvoted: Boolean
  }

  connect() {
    this.updateUpvoteButton()
  }

  toggleUpvote(event) {
    event.preventDefault()
    
    const url = `/products/${this.productIdValue}/toggle_upvote`
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
    .catch(error => {
      console.error('Error toggling upvote:', error)
      this.showNotification('Failed to toggle upvote', 'error')
    })
  }

  updateUpvoteButton() {
    if (this.hasUpvoteButtonTarget) {
      const icon = this.upvoteButtonTarget.querySelector('svg')
      const count = this.upvoteButtonTarget.querySelector('span')
      
      if (this.upvotedValue) {
        icon.classList.add('text-blue-600')
        icon.classList.remove('text-gray-600')
      } else {
        icon.classList.remove('text-blue-600')
        icon.classList.add('text-gray-600')
      }
    }
  }

  submitComment(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    const url = form.action
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    // Disable submit button
    const submitButton = form.querySelector('button[type="submit"], input[type="submit"]')
    const originalText = submitButton.textContent
    submitButton.disabled = true
    submitButton.textContent = 'Posting...'

    fetch(url, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: formData,
      credentials: 'same-origin'
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
      this.showNotification('Comment posted successfully!', 'success')
    })
    .catch(error => {
      console.error('Error posting comment:', error)
      this.showNotification('Failed to post comment', 'error')
    })
    .finally(() => {
      // Re-enable submit button
      submitButton.disabled = false
      submitButton.textContent = originalText
    })
  }

  deleteComment(event) {
    event.preventDefault()
    
    if (!confirm('Are you sure you want to delete this comment?')) {
      return
    }

    const url = event.currentTarget.href
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')

    fetch(url, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': token,
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json'
      },
      credentials: 'same-origin'
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
      this.showNotification('Comment deleted successfully!', 'success')
    })
    .catch(error => {
      console.error('Error deleting comment:', error)
      this.showNotification('Failed to delete comment', 'error')
    })
  }

  showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg transform transition-all duration-300 translate-x-full`
    
    // Set color based on type
    switch (type) {
      case 'success':
        notification.classList.add('bg-green-500', 'text-white')
        break
      case 'error':
        notification.classList.add('bg-red-500', 'text-white')
        break
      default:
        notification.classList.add('bg-blue-500', 'text-white')
    }

    notification.innerHTML = `
      <div class="flex items-center">
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
          ${type === 'success' ? 
            '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>' :
            type === 'error' ?
            '<path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.415 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.415L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>' :
            '<path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>'
          }
        </svg>
        <span>${message}</span>
      </div>
    `

    document.body.appendChild(notification)

    // Animate in
    setTimeout(() => {
      notification.classList.remove('translate-x-full')
      notification.classList.add('translate-x-0')
    }, 100)

    // Remove after 3 seconds
    setTimeout(() => {
      notification.classList.add('translate-x-full')
      setTimeout(() => {
        document.body.removeChild(notification)
      }, 300)
    }, 3000)
  }

  // Auto-save draft functionality
  autoSave() {
    const form = this.commentFormTarget
    const content = form.querySelector('textarea[name="comment[content]"]').value
    
    if (content.trim().length > 0) {
      localStorage.setItem(`comment_draft_${this.productIdValue}`, content)
    }
  }

  loadDraft() {
    const draft = localStorage.getItem(`comment_draft_${this.productIdValue}`)
    if (draft && this.hasCommentFormTarget) {
      const textarea = this.commentFormTarget.querySelector('textarea[name="comment[content]"]')
      if (textarea) {
        textarea.value = draft
        this.updateCharCount(textarea)
      }
    }
  }

  clearDraft() {
    localStorage.removeItem(`comment_draft_${this.productIdValue}`)
  }
}