import { Controller } from "@hotwired/stimulus"
import { readCart, writeCart, findCartItem, formatPrice } from "cart"

export default class extends Controller {
  static targets = [
    "scrim", "modal", "media", "category", "name", "price", "comparePrice",
    "flag", "description", "colorSection", "colorRow", "sizeSection", "sizeRow",
    "qty", "addButton", "addButtonLabel", "stockHint", "incrementBtn",
  ]

  connect() {
    this.product = null
    this.size = null
    this.color = null
    this.qty = 1
  }

  stop(event) {
    event.stopPropagation()
  }

  open(event) {
    this.product = JSON.parse(event.currentTarget.dataset.product)
    this.qty = 1
    this.size = this.product.sizes.includes("M") ? "M" : (this.product.sizes[0] || null)
    const swatches = this.product.swatches || []
    this.color = swatches.length ? swatches[0].name : null

    this.qty = Math.min(this.qty, this.stockFor(this.size, this.color) ?? Infinity) || 1

    this.categoryTarget.textContent = this.product.category
    this.nameTarget.textContent = this.product.name
    this.descriptionTarget.textContent = this.product.description ||
      "Pieza de la colección naar, confeccionada con telas de calidad y buena caída. Combínala con tus básicos favoritos."

    if (this.product.flag) {
      this.flagTarget.textContent = this.product.flag
      this.flagTarget.style.display = ""
    } else {
      this.flagTarget.style.display = "none"
    }

    if (this.product.compareAtPrice) {
      this.comparePriceTarget.textContent = `$${this.formatPrice(this.product.compareAtPrice)}`
      this.comparePriceTarget.style.display = ""
    } else {
      this.comparePriceTarget.style.display = "none"
    }

    this.renderColors()
    this.renderSizes()
    this.renderMedia()
    this.renderQty()
    this.updatePrice()

    this.modalTarget.classList.add("is-open")
    this.scrimTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.modalTarget.classList.remove("is-open")
    this.scrimTarget.classList.remove("is-open")
    document.body.style.overflow = ""
  }

  renderMedia() {
    this.slides = this.buildSlides()
    this.slideIndex = 0
    this.paintSlides()
  }

  buildSlides() {
    const imagesByColor = this.product.imagesByColor || {}
    const slides = (this.color && imagesByColor[this.color]) || this.product.images || []

    return slides.length ? slides : (this.product.image ? [ this.product.image ] : [])
  }

  paintSlides() {
    this.mediaTarget.innerHTML = ""

    this.slides.forEach((src, i) => {
      const img = document.createElement("img")
      img.src = src
      img.alt = this.product.name
      img.className = `media-carousel-slide ${i === this.slideIndex ? "is-active" : ""}`
      this.mediaTarget.appendChild(img)
    })

    if (this.slides.length <= 1) return

    const prev = document.createElement("button")
    prev.type = "button"
    prev.className = "media-carousel-arrow prev"
    prev.setAttribute("aria-label", "Foto anterior")
    prev.dataset.action = "product-modal#prevSlide"
    prev.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M15 18l-6-6 6-6"/></svg>`
    this.mediaTarget.appendChild(prev)

    const next = document.createElement("button")
    next.type = "button"
    next.className = "media-carousel-arrow next"
    next.setAttribute("aria-label", "Foto siguiente")
    next.dataset.action = "product-modal#nextSlide"
    next.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M9 18l6-6-6-6"/></svg>`
    this.mediaTarget.appendChild(next)

    const dots = document.createElement("div")
    dots.className = "media-carousel-dots"
    this.slides.forEach((_, i) => {
      const dot = document.createElement("button")
      dot.type = "button"
      dot.className = `media-carousel-dot ${i === this.slideIndex ? "is-active" : ""}`
      dot.dataset.action = "product-modal#goToSlide"
      dot.dataset.index = i
      dots.appendChild(dot)
    })
    this.mediaTarget.appendChild(dots)
  }

  prevSlide() {
    this.slideIndex = (this.slideIndex - 1 + this.slides.length) % this.slides.length
    this.paintSlides()
  }

  nextSlide() {
    this.slideIndex = (this.slideIndex + 1) % this.slides.length
    this.paintSlides()
  }

  goToSlide(event) {
    this.slideIndex = Number(event.currentTarget.dataset.index)
    this.paintSlides()
  }

  renderColors() {
    const swatches = this.product.swatches || []
    this.colorSectionTarget.style.display = swatches.length ? "" : "none"
    this.colorRowTarget.innerHTML = ""
    swatches.forEach((s) => {
      const stock = this.stockFor(this.size, s.name)
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = `size-pill ${s.name === this.color ? "is-active" : ""} ${stock === 0 ? "is-unavailable" : ""}`
      btn.textContent = s.name
      btn.dataset.action = "product-modal#selectColor"
      btn.dataset.color = s.name
      this.colorRowTarget.appendChild(btn)
    })
  }

  selectColor(event) {
    this.color = event.currentTarget.dataset.color
    this.renderColors()
    this.renderSizes()
    this.renderMedia()
    this.clampQtyToStock()
    this.updatePrice()
  }

  renderSizes() {
    this.sizeSectionTarget.style.display = this.product.sizes.length ? "" : "none"
    this.sizeRowTarget.innerHTML = ""
    this.product.sizes.forEach((s) => {
      const stock = this.stockFor(s, this.color)
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = `size-pill ${s === this.size ? "is-active" : ""} ${stock === 0 ? "is-unavailable" : ""}`
      btn.textContent = s
      btn.dataset.action = "product-modal#selectSize"
      btn.dataset.size = s
      this.sizeRowTarget.appendChild(btn)
    })
  }

  selectSize(event) {
    this.size = event.currentTarget.dataset.size
    this.renderSizes()
    this.renderColors()
    this.clampQtyToStock()
    this.updatePrice()
  }

  // Stock de la variante actualmente seleccionada (talla + color). `null`/`undefined`
  // significa que no se trackea stock para esa variante (sin límite).
  stockFor(size, color) {
    const variants = this.product.variants || []
    const match = variants.find((v) => v.size === size && v.color === color)
    return match ? match.stock : null
  }

  clampQtyToStock() {
    const stock = this.stockFor(this.size, this.color)
    if (stock != null) this.qty = Math.min(this.qty, Math.max(stock, 1))
    this.renderQty()
  }

  increment() {
    const stock = this.stockFor(this.size, this.color)
    if (stock == null || this.qty < stock) this.qty += 1
    this.renderQty()
    this.updatePrice()
  }

  decrement() {
    this.qty = Math.max(1, this.qty - 1)
    this.renderQty()
    this.updatePrice()
  }

  renderQty() {
    this.qtyTarget.textContent = this.qty

    const stock = this.stockFor(this.size, this.color)
    const outOfStock = stock != null && stock <= 0

    if (this.hasStockHintTarget) {
      this.stockHintTarget.textContent = outOfStock ? "Sin stock" : ""
    }
    if (this.hasAddButtonTarget) this.addButtonTarget.disabled = outOfStock
    if (this.hasIncrementBtnTarget) this.incrementBtnTarget.disabled = stock != null && this.qty >= stock
  }

  updatePrice() {
    const total = this.product.price * this.qty
    const stock = this.stockFor(this.size, this.color)

    this.priceTarget.textContent = `$${this.formatPrice(this.product.price)}`
    this.addButtonLabelTarget.textContent = (stock != null && stock <= 0)
      ? "Sin stock"
      : `Agregar al carrito · $${this.formatPrice(total)}`
  }

  addToCart() {
    const stock = this.stockFor(this.size, this.color)
    const cart = readCart()
    const existing = findCartItem(cart, this.product.id, this.size, this.color)

    if (existing) {
      existing.qty += this.qty
      if (stock != null) existing.qty = Math.min(existing.qty, stock)
      existing.stock = stock
    } else {
      cart.push({
        id: this.product.id,
        name: this.product.name,
        size: this.size,
        color: this.color,
        qty: this.qty,
        price: this.product.price,
        image: this.slides[0] || this.product.image,
        stock: stock,
      })
    }

    writeCart(cart)
    this.flashAdded()
  }

  flashAdded() {
    const label = this.addButtonLabelTarget
    const previous = label.textContent
    label.textContent = "¡Agregado! ✓"
    clearTimeout(this.flashTimeout)
    this.flashTimeout = setTimeout(() => {
      label.textContent = previous
    }, 1500)
  }

  formatPrice(n) {
    return formatPrice(n)
  }
}
