import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["compareAtPrice", "flag"]

  sync() {
    const value = parseFloat(this.compareAtPriceTarget.value)

    if (value > 0) {
      this.flagTarget.value = "oferta"
    } else {
      this.flagTarget.value = "sin_flag"
    }
  }
}
