import { Controller } from "@hotwired/stimulus"

document.addEventListener("turbo:submit-start", (event) => {
  if (event.target.closest("#variantes")) {
    sessionStorage.setItem("variantesScrollY", window.scrollY)
  }
})

document.addEventListener("turbo:load", () => {
  const y = sessionStorage.getItem("variantesScrollY")
  if (y !== null) {
    window.scrollTo(0, parseInt(y, 10))
    sessionStorage.removeItem("variantesScrollY")
  }
})

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

  duplicate(event) {
    const { colorName, colorHex, size, sku, stock } = event.currentTarget.dataset
    this.newRowTarget.querySelector("#product_variant_color_name_new").value = colorName || ""
    this.newRowTarget.querySelector("#color_hex_text_new").value = colorHex || ""
    this.newRowTarget.querySelector("#color_picker_new").value = colorHex || "#000000"
    this.newRowTarget.querySelector("#product_variant_size_new").value = size || ""
    this.newRowTarget.querySelector("#product_variant_sku_new").value = sku || ""
    this.newRowTarget.querySelector("#product_variant_stock_new").value = stock || ""
    this.showNew()
  }

  cancelNew() {
    this.newRowTarget.classList.add("d-none")
    this.addButtonTarget.classList.remove("d-none")
  }

  rowFor(list, id) {
    return list.find((row) => row.dataset.variantId === id)
  }
}
