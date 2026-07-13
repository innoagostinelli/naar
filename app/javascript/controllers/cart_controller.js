import { Controller } from "@hotwired/stimulus"
import { readCart, writeCart, cartCount, cartTotal, formatPrice, buildWhatsAppMessage, WHATSAPP_NUMBER } from "cart"
import { showToast } from "toast"

const CHECKOUT_INFO_KEY = "naar_checkout_info"

export default class extends Controller {
  static targets = [
    "scrim", "drawer", "items", "empty", "foot", "count", "subtotal", "total", "badge", "checkoutLabel",
    "form", "customerName", "customerPhone", "addressSection", "address", "country", "state", "city", "locationsData",
    "itemsSummary", "customerSummary", "addressSummary",
  ]

  connect() {
    this.locations = JSON.parse(this.locationsDataTarget.textContent || "[]")
    this.populateStateOptions()
    this.renderBadge()
    this.boundRefresh = () => {
      this.renderBadge()
      if (this.drawerTarget.classList.contains("is-open")) this.render()
    }
    window.addEventListener("naar:cart-updated", this.boundRefresh)
  }

  disconnect() {
    window.removeEventListener("naar:cart-updated", this.boundRefresh)
  }

  open() {
    this.render()
    this.restoreCheckoutInfo()
    this.openSection("items")
    this.drawerTarget.classList.add("is-open")
    this.scrimTarget.classList.add("is-open")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.drawerTarget.classList.remove("is-open")
    this.scrimTarget.classList.remove("is-open")
    document.body.style.overflow = ""
  }

  render() {
    const cart = readCart()
    this.countTarget.textContent = cart.length

    this.itemsTarget.innerHTML = ""
    const hasItems = cart.length > 0
    this.emptyTarget.style.display = hasItems ? "none" : ""
    this.footTarget.style.display = hasItems ? "" : "none"
    if (!hasItems) return

    cart.forEach((item, index) => this.itemsTarget.appendChild(this.buildItemEl(item, index)))
    this.updateTotals(cart)
    this.itemsSummaryTarget.textContent =
      `${cart.length} producto${cart.length === 1 ? "" : "s"} · $${formatPrice(cartTotal(cart))}`
  }

  buildItemEl(item, index) {
    const el = document.createElement("div")
    el.className = "cart-item"

    const thumb = document.createElement("div")
    thumb.className = "cart-thumb"
    if (item.image) {
      const img = document.createElement("img")
      img.src = item.image
      img.alt = item.name
      thumb.appendChild(img)
    }

    const info = document.createElement("div")
    info.className = "cart-info"

    const name = document.createElement("h4")
    name.textContent = item.name
    info.appendChild(name)

    const variant = [item.size, item.color].filter(Boolean).join(" / ")
    if (variant) {
      const p = document.createElement("p")
      p.textContent = variant
      info.appendChild(p)
    }

    const qtyRow = document.createElement("div")
    qtyRow.className = "qty-row"

    const minusBtn = document.createElement("button")
    minusBtn.type = "button"
    minusBtn.className = "qty-btn"
    minusBtn.textContent = "−"
    minusBtn.dataset.action = "cart#decrementItem"
    minusBtn.dataset.index = index

    const qtySpan = document.createElement("span")
    qtySpan.style.cssText = "min-width:20px; text-align:center; font-weight:600;"
    qtySpan.textContent = item.qty

    const plusBtn = document.createElement("button")
    plusBtn.type = "button"
    plusBtn.className = "qty-btn"
    plusBtn.textContent = "+"
    plusBtn.dataset.action = "cart#incrementItem"
    plusBtn.dataset.index = index

    const removeBtn = document.createElement("button")
    removeBtn.type = "button"
    removeBtn.textContent = "Quitar"
    removeBtn.style.cssText = "margin-left:12px; font-size:12px; color:var(--ink-soft); text-decoration:underline;"
    removeBtn.dataset.action = "cart#removeItem"
    removeBtn.dataset.index = index

    qtyRow.append(minusBtn, qtySpan, plusBtn, removeBtn)
    info.appendChild(qtyRow)

    const price = document.createElement("div")
    price.className = "cart-price"
    price.textContent = `$${formatPrice(item.price * item.qty)}`

    el.append(thumb, info, price)
    return el
  }

  incrementItem(event) {
    this.mutateQty(event, 1)
  }

  decrementItem(event) {
    this.mutateQty(event, -1)
  }

  mutateQty(event, delta) {
    const cart = readCart()
    const index = Number(event.currentTarget.dataset.index)
    cart[index].qty = Math.max(1, cart[index].qty + delta)
    writeCart(cart)
    this.render()
  }

  removeItem(event) {
    const cart = readCart()
    const index = Number(event.currentTarget.dataset.index)
    cart.splice(index, 1)
    writeCart(cart)
    this.render()
  }

  updateTotals(cart) {
    const total = cartTotal(cart)
    this.subtotalTarget.textContent = `$${formatPrice(total)}`
    this.totalTarget.textContent = `$${formatPrice(total)}`
  }

  renderBadge() {
    if (this.hasBadgeTarget) this.badgeTarget.textContent = cartCount()
  }

  toggleFulfillment(event) {
    const isDelivery = event.target.value === "delivery"
    this.addressSectionTarget.style.display = isDelivery ? "" : "none"
    this.addressTarget.required = isDelivery
    this.stateTarget.required = isDelivery
    this.cityTarget.required = isDelivery

    if (isDelivery) {
      this.openSection("address")
    } else if (this.currentSection() === "address") {
      this.openSection("customer")
    }

    this.persistCheckoutInfo()
  }

  toggleSection(event) {
    const section = event.currentTarget.closest(".checkout-section")
    if (section.classList.contains("is-open")) {
      this.element.querySelectorAll(".checkout-section").forEach((el) => el.classList.remove("is-open"))
    } else {
      this.openSection(section.dataset.section)
    }
  }

  openSection(name) {
    this.element.querySelectorAll(".checkout-section").forEach((el) => {
      el.classList.toggle("is-open", el.dataset.section === name)
    })
  }

  currentSection() {
    const open = this.element.querySelector(".checkout-section.is-open")
    return open ? open.dataset.section : null
  }

  populateStateOptions() {
    this.locations.forEach((state) => {
      const opt = document.createElement("option")
      opt.value = state.id
      opt.textContent = state.name
      this.stateTarget.appendChild(opt)
    })
  }

  onStateChange(event) {
    this.populateCities(Number(event.target.value))
    this.persistCheckoutInfo()
  }

  populateCities(stateId, selectedCityId = null) {
    const state = this.locations.find((s) => s.id === stateId)
    this.cityTarget.innerHTML = ""

    if (!state || !state.cities.length) {
      this.cityTarget.disabled = true
      const placeholder = document.createElement("option")
      placeholder.value = ""
      placeholder.disabled = true
      placeholder.selected = true
      placeholder.textContent = "Selecciona un estado primero"
      this.cityTarget.appendChild(placeholder)
      return
    }

    this.cityTarget.disabled = false
    const placeholder = document.createElement("option")
    placeholder.value = ""
    placeholder.disabled = true
    placeholder.selected = !selectedCityId
    placeholder.textContent = "Selecciona una ciudad"
    this.cityTarget.appendChild(placeholder)

    state.cities.forEach((city) => {
      const opt = document.createElement("option")
      opt.value = city.id
      opt.textContent = city.name
      if (selectedCityId && city.id === selectedCityId) opt.selected = true
      this.cityTarget.appendChild(opt)
    })
  }

  persistCheckoutInfo() {
    const selected = this.formTarget.querySelector('input[name="fulfillment"]:checked')
    localStorage.setItem(CHECKOUT_INFO_KEY, JSON.stringify({
      customerName: this.customerNameTarget.value,
      customerPhone: this.customerPhoneTarget.value,
      fulfillment: selected ? selected.value : null,
      country: this.countryTarget.value,
      stateId: this.stateTarget.value || null,
      cityId: this.cityTarget.value || null,
      address: this.addressTarget.value,
    }))
    this.updateCheckoutSummaries()
  }

  updateCheckoutSummaries() {
    const selected = this.formTarget.querySelector('input[name="fulfillment"]:checked')
    const fulfillmentLabel = selected ? (selected.value === "delivery" ? "Delivery" : "Retiro en tienda") : ""
    this.customerSummaryTarget.textContent =
      [ this.customerNameTarget.value, fulfillmentLabel ].filter(Boolean).join(" · ")

    const state = this.locations.find((s) => s.id === Number(this.stateTarget.value))
    const city = state?.cities.find((c) => c.id === Number(this.cityTarget.value))
    this.addressSummaryTarget.textContent = [ city?.name, state?.name ].filter(Boolean).join(", ")
  }

  restoreCheckoutInfo() {
    let info
    try {
      info = JSON.parse(localStorage.getItem(CHECKOUT_INFO_KEY))
    } catch (e) {
      return
    }
    if (!info) return

    if (info.customerName) this.customerNameTarget.value = info.customerName
    if (info.customerPhone) this.customerPhoneTarget.value = info.customerPhone
    if (info.country) this.countryTarget.value = info.country
    if (info.address) this.addressTarget.value = info.address
    if (info.stateId) {
      this.stateTarget.value = info.stateId
      this.populateCities(Number(info.stateId), info.cityId ? Number(info.cityId) : null)
    }
    if (info.fulfillment) {
      const radio = this.formTarget.querySelector(`input[name="fulfillment"][value="${info.fulfillment}"]`)
      if (radio) {
        radio.checked = true
        const isDelivery = info.fulfillment === "delivery"
        this.addressSectionTarget.style.display = isDelivery ? "" : "none"
        this.addressTarget.required = isDelivery
        this.stateTarget.required = isDelivery
        this.cityTarget.required = isDelivery
      }
    }

    this.updateCheckoutSummaries()
  }

  async checkout(event) {
    const cart = readCart()
    if (!cart.length) return

    if (!this.formTarget.checkValidity()) {
      const invalid = this.formTarget.querySelector(":invalid")
      const section = invalid?.closest(".checkout-section")
      if (section) this.openSection(section.dataset.section)
      this.formTarget.reportValidity()
      return
    }

    const customer = {
      customerName: this.customerNameTarget.value,
      customerPhone: this.customerPhoneTarget.value,
      fulfillmentMethod: this.formTarget.querySelector('input[name="fulfillment"]:checked').value,
      country: this.countryTarget.value,
      stateId: this.stateTarget.value || null,
      cityId: this.cityTarget.value || null,
      address: this.addressTarget.value,
    }

    const button = event.currentTarget
    const label = this.checkoutLabelTarget
    const previousLabel = label.textContent
    button.disabled = true
    label.textContent = "Enviando pedido..."

    try {
      const response = await fetch("/orders", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content,
        },
        body: JSON.stringify({
          items: cart,
          customer_name: customer.customerName,
          customer_phone: customer.customerPhone,
          fulfillment_method: customer.fulfillmentMethod,
          country: customer.country,
          state_id: customer.stateId,
          city_id: customer.cityId,
          address: customer.address,
        }),
      })
      if (!response.ok) throw new Error("No se pudo guardar el pedido")

      const data = await response.json()
      const message = buildWhatsAppMessage(data.url)
      window.open(`https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(message)}`, "_blank", "noopener")

      writeCart([])
      this.close()
      showToast("¡Pedido enviado! Coordinamos por WhatsApp.")
    } catch (e) {
      alert("No pudimos guardar tu pedido. Por favor intenta de nuevo.")
    } finally {
      button.disabled = false
      label.textContent = previousLabel
    }
  }
}
