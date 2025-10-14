import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="skeleton-loader"
// Shows skeleton loading states instead of spinners
export default class extends Controller {
  static targets = ["content", "skeleton"]
  static values = {
    loaded: { type: Boolean, default: false },
    delay: { type: Number, default: 300 }
  }

  connect() {
    console.log("Skeleton loader controller connected")
    
    // Show skeleton initially
    if (!this.loadedValue) {
      this.showSkeleton()
    }
  }

  // Show skeleton loading state
  showSkeleton() {
    if (this.hasSkeletonTarget && this.hasContentTarget) {
      this.skeletonTarget.classList.remove('hidden')
      this.contentTarget.classList.add('hidden')
    }
  }

  // Hide skeleton and show content
  hideSkeletonAndShowContent() {
    if (this.hasSkeletonTarget && this.hasContentTarget) {
      // Add fade-in animation
      this.contentTarget.classList.add('animate-fade-in')
      
      setTimeout(() => {
        this.skeletonTarget.classList.add('hidden')
        this.contentTarget.classList.remove('hidden')
        this.loadedValue = true
      }, this.delayValue)
    }
  }

  // Mark as loaded
  loaded() {
    this.hideSkeletonAndShowContent()
  }

  // Reload - show skeleton again
  reload() {
    this.loadedValue = false
    this.showSkeleton()
  }
}

