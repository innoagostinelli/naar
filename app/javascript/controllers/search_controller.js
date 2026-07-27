import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_MS = 300

export default class extends Controller {
  static targets = ["scrim", "panel", "input", "form"]

  open() {
    this.panelTarget.classList.add("is-open")
    this.scrimTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
    requestAnimationFrame(() => this.inputTarget.focus())
  }

  close() {
    this.panelTarget.classList.remove("is-open")
    this.scrimTarget.classList.remove("is-open")
    document.body.style.overflow = ""
    clearTimeout(this.timeout)
    if (this.inputTarget.value !== "") {
      this.inputTarget.value = ""
      this.formTarget.requestSubmit()
    }
  }

  debounceSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.formTarget.requestSubmit(), DEBOUNCE_MS)
  }
}
