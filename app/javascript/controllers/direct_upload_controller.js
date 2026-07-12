import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "progressWrap", "progressBar", "status", "submit"]

  connect() {
    this.originalStatusText = this.hasStatusTarget ? this.statusTarget.textContent : ""
    this.inputTarget.addEventListener("direct-upload:initialize", this.onInitialize.bind(this))
    this.inputTarget.addEventListener("direct-upload:progress", this.onProgress.bind(this))
    this.inputTarget.addEventListener("direct-upload:error", this.onError.bind(this))
    this.inputTarget.addEventListener("direct-upload:end", this.onEnd.bind(this))
  }

  onInitialize() {
    this.progressWrapTarget.style.display = ""
    this.progressBarTarget.style.width = "0%"
    if (this.hasStatusTarget) this.statusTarget.textContent = "Subiendo video..."
    if (this.hasSubmitTarget) this.submitTarget.disabled = true
  }

  onProgress(event) {
    const { progress } = event.detail
    this.progressBarTarget.style.width = `${progress}%`
  }

  onError(event) {
    event.preventDefault()
    if (this.hasStatusTarget) this.statusTarget.textContent = `Error al subir: ${event.detail.error}`
    if (this.hasSubmitTarget) this.submitTarget.disabled = false
  }

  onEnd() {
    this.progressWrapTarget.style.display = "none"
    if (this.hasStatusTarget) this.statusTarget.textContent = this.originalStatusText
    if (this.hasSubmitTarget) this.submitTarget.disabled = false
  }
}
