import { Controller } from "@hotwired/stimulus"

document.addEventListener("turbo:submit-start", (event) => {
  if (event.target.closest("#variantes")) {
    sessionStorage.setItem("variantesScrollY", window.scrollY)

    // Guardar una variante recarga toda la página — si había OTRAS filas en
    // edición (sin guardar todavía), se guarda cuáles eran para reabrirlas
    // solas después del reload, en vez de perder ese estado. La fila que se
    // está guardando queda afuera: esa vuelve a modo "display" como corresponde.
    const submittedId = event.target.id.replace("variant_form_", "")
    const openIds = Array.from(document.querySelectorAll('tr[data-variant-rows-target="formRow"]:not(.d-none)'))
      .map((row) => row.dataset.variantId)
      .filter((id) => id !== submittedId)
    sessionStorage.setItem("variantesOpenEdits", JSON.stringify(openIds))
  }
})

document.addEventListener("turbo:load", () => {
  const y = sessionStorage.getItem("variantesScrollY")
  if (y !== null) {
    window.scrollTo(0, parseInt(y, 10))
    sessionStorage.removeItem("variantesScrollY")
  }

  const openIdsRaw = sessionStorage.getItem("variantesOpenEdits")
  if (openIdsRaw !== null) {
    JSON.parse(openIdsRaw).forEach((id) => {
      const displayRow = document.querySelector(`tr[data-variant-rows-target="displayRow"][data-variant-id="${id}"]`)
      const formRow = document.querySelector(`tr[data-variant-rows-target="formRow"][data-variant-id="${id}"]`)
      if (displayRow && formRow) {
        displayRow.classList.add("d-none")
        formRow.classList.remove("d-none")
      }
    })
    sessionStorage.removeItem("variantesOpenEdits")
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
    this.newRowTarget.querySelector("#product_variant_sku_new").value = sku || ""
    this.newRowTarget.querySelector("#product_variant_stock_new").value = stock || ""

    // El select de talla se repuebla según el switch letras/números — hay que
    // pasar por el controller para que elija el modo correcto antes de fijar el valor.
    const sizeTypeEl = this.newRowTarget.querySelector('[data-controller~="size-type"]')
    this.application.getControllerForElementAndIdentifier(sizeTypeEl, "size-type")?.setValue(size || "")

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
