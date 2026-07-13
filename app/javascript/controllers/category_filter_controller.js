import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tile", "section"]

  filter(event) {
    const tile = event.currentTarget
    const slug = tile.dataset.slug

    this.tileTargets.forEach(t => t.classList.remove("is-active"))
    tile.classList.add("is-active")

    if (slug === "all") {
      this.sectionTargets.forEach(s => s.hidden = false)
      this.sectionTargets.find(s => s.dataset.category === "nuevos")
        ?.scrollIntoView({ behavior: "smooth", block: "start" })
    } else {
      this.sectionTargets.forEach(s => {
        s.hidden = s.dataset.category !== slug
      })

      const target = this.sectionTargets.find(s => s.dataset.category === slug)
      target?.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }
}
