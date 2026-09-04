import { Controller } from "@hotwired/stimulus"

// Switch "Letras" / "Números" para la talla de una variante (ver Amazon/Macy's:
// las tiendas de ropa manejan la talla como un "size type" que determina qué
// lista de valores está disponible, en vez de un único select fijo o texto libre).
// Mantener sincronizado con Product::ALPHA_SIZES / Product::NUMERIC_SIZES.
const ALPHA = [ "XS", "S", "M", "L", "XL", "XXL", "Único" ]
const NUMERIC = Array.from({ length: 8 }, (_, i) => String(24 + i)) // 24..31

export default class extends Controller {
  static targets = [ "select", "alphaBtn", "numericBtn" ]

  connect() {
    const current = this.selectTarget.dataset.current || ""
    // Fila nueva (sin valor todavía): arranca en el modo de la última
    // variante cargada (default_mode, ver edit.html.erb) en vez de "alpha" fijo.
    const mode = current ? (NUMERIC.includes(current) ? "numeric" : "alpha")
                          : (this.selectTarget.dataset.defaultMode || "alpha")
    this.applyMode(mode, current)
  }

  setMode(event) {
    this.applyMode(event.params.mode, this.selectTarget.value)
  }

  // Llamado desde variant-rows#duplicate para precargar la talla de la fila
  // "nueva variante", eligiendo el modo correcto antes de fijar el valor.
  setValue(value) {
    const mode = NUMERIC.includes(value) ? "numeric" : "alpha"
    this.applyMode(mode, value)
  }

  applyMode(mode, preserveValue) {
    const options = mode === "numeric" ? NUMERIC : ALPHA
    this.selectTarget.innerHTML = options
      .map((opt) => `<option value="${opt}">${opt}</option>`)
      .join("")
    if (options.includes(preserveValue)) this.selectTarget.value = preserveValue

    this.alphaBtnTarget.classList.toggle("active", mode === "alpha")
    this.numericBtnTarget.classList.toggle("active", mode === "numeric")
  }
}
