import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["displayRow", "formRow", "newRow", "addButton"]

  edit(event) {
    const id = event.currentTarget.dataset.variantId
    this.rowFor(this.displayRowTargets, id).classList.add("d-none")
    this.rowFor(this.formRowTargets, id).classList.remove("d-none")
  }

  cancelEdit(event) {
    const id = event.currentTarget.dataset.variantId
    this.rowFor(this.formRowTargets, id).classList.add("d-none")
    this.rowFor(this.displayRowTargets, id).classList.remove("d-none")
  }

  showNew() {
    this.newRowTarget.classList.remove("d-none")
    this.addButtonTarget.classList.add("d-none")
  }

  cancelNew() {
    this.newRowTarget.classList.add("d-none")
    this.addButtonTarget.classList.remove("d-none")
  }

  rowFor(list, id) {
    return list.find((row) => row.dataset.variantId === id)
  }
}
