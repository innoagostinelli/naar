import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]

  connect() {
    this.index = 0
  }

  start() {
    if (this.slideTargets.length <= 1) return

    this.interval = setInterval(() => {
      this.index = (this.index + 1) % this.slideTargets.length
      this.render()
    }, 900)
  }

  stop() {
    clearInterval(this.interval)
    this.index = 0
    this.render()
  }

  render() {
    this.slideTargets.forEach((el, i) => el.classList.toggle("is-active", i === this.index))
  }
}
