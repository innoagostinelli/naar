import { Controller } from "@hotwired/stimulus"

const DISMISSED_KEY = "naar_banner_dismissed"

export default class extends Controller {
  static targets = ["scrim", "modal"]

  connect() {
    if (sessionStorage.getItem(DISMISSED_KEY)) return
    requestAnimationFrame(() => this.open())
  }

  open() {
    this.modalTarget.classList.add("is-open")
    this.scrimTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }

  dismiss() {
    this.modalTarget.classList.remove("is-open")
    this.scrimTarget.classList.remove("is-open")
    document.body.style.overflow = ""
    sessionStorage.setItem(DISMISSED_KEY, "1")
  }
}
