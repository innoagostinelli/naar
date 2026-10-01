import { Controller } from "@hotwired/stimulus"

// Vista previa flotante de la miniatura de producto en el listado del admin.
// Al entrar con el mouse arranca una espera (`delay`, ms) con un anillo de carga
// junto al puntero; si se sale antes se cancela. La imagen grande se empieza a
// descargar al comenzar la espera, así está lista cuando aparece el popup.
export default class extends Controller {
  static values = { delay: { type: Number, default: 3000 } }
  static GAP = 12

  connect() {
    this.popup = this.buildPopup()
    this.loader = this.buildLoader()
    this.trackPointer = (event) => this.moveLoader(event)
  }

  disconnect() {
    this.cancel()
    this.popup.remove()
    this.loader.remove()
  }

  show(event) {
    const thumb = event.currentTarget
    const url = thumb.dataset.previewUrl
    if (!url) return

    this.cancel()
    this.load(url)

    this.loader.style.setProperty("--delay", `${this.delayValue}ms`)
    this.moveLoader(event)
    this.loader.classList.add("is-active")
    thumb.addEventListener("mousemove", this.trackPointer)
    this.activeThumb = thumb

    this.timer = setTimeout(() => {
      this.hideLoader()
      this.position(thumb)
      this.popup.classList.add("is-visible")
    }, this.delayValue)
  }

  hide() {
    this.cancel()
    this.popup.classList.remove("is-visible")
  }

  // private

  cancel() {
    clearTimeout(this.timer)
    this.hideLoader()
  }

  hideLoader() {
    this.loader.classList.remove("is-active")
    this.activeThumb?.removeEventListener("mousemove", this.trackPointer)
    this.activeThumb = null
  }

  load(url) {
    if (this.image.getAttribute("src") === url) return

    this.popup.classList.add("is-loading")
    this.image.onload = () => this.popup.classList.remove("is-loading")
    this.image.src = url
  }

  moveLoader(event) {
    this.loader.style.left = `${event.clientX + 14}px`
    this.loader.style.top = `${event.clientY + 14}px`
  }

  // A la derecha de la miniatura, centrado vertical y siempre dentro de la ventana.
  position(thumb) {
    const rect = thumb.getBoundingClientRect()
    const height = this.popup.offsetHeight
    const gap = this.constructor.GAP

    let top = rect.top + rect.height / 2 - height / 2
    top = Math.max(gap, Math.min(top, window.innerHeight - height - gap))

    this.popup.style.left = `${rect.right + gap}px`
    this.popup.style.top = `${top}px`
    this.popup.style.setProperty("--origin-y", `${rect.top + rect.height / 2 - top}px`)
  }

  buildPopup() {
    const popup = document.createElement("div")
    popup.className = "thumb-preview"
    popup.setAttribute("aria-hidden", "true")
    this.image = document.createElement("img")
    this.image.alt = ""
    popup.appendChild(this.image)
    document.body.appendChild(popup)
    return popup
  }

  // Anillo SVG que se completa en `--delay`.
  buildLoader() {
    const loader = document.createElement("div")
    loader.className = "thumb-preview-loader"
    loader.setAttribute("aria-hidden", "true")
    loader.innerHTML = `
      <svg viewBox="0 0 24 24" width="22" height="22">
        <circle class="track" cx="12" cy="12" r="9" />
        <circle class="progress" cx="12" cy="12" r="9" pathLength="100" />
      </svg>`
    document.body.appendChild(loader)
    return loader
  }
}
