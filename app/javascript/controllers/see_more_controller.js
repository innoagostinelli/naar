import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["extra", "button"]

  expand() {
    this.extraTargets.forEach(el => el.classList.add("is-visible"))
    this.buttonTarget.hidden = true
  }
}
