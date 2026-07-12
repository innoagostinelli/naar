import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrim", "menu"]

  open() {
    this.menuTarget.classList.add("is-open")
    this.scrimTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.menuTarget.classList.remove("is-open")
    this.scrimTarget.classList.remove("is-open")
    document.body.style.overflow = ""
  }
}
