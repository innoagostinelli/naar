export const CART_KEY = "naar_cart"
export const WHATSAPP_NUMBER = "584120511634"

export function readCart() {
  try {
    return JSON.parse(localStorage.getItem(CART_KEY)) || []
  } catch (e) {
    return []
  }
}

export function dispatchCartUpdated() {
  window.dispatchEvent(new CustomEvent("naar:cart-updated"))
}

export function writeCart(cart) {
  localStorage.setItem(CART_KEY, JSON.stringify(cart))
  dispatchCartUpdated()
}

export function cartCount(cart = readCart()) {
  return cart.reduce((sum, i) => sum + i.qty, 0)
}

export function cartTotal(cart = readCart()) {
  return cart.reduce((sum, i) => sum + i.price * i.qty, 0)
}

export function formatPrice(n) {
  return Math.trunc(n)
}

export function findCartItem(cart, id, size, color) {
  return cart.find((i) => i.id === id && i.size === size && i.color === color)
}

export function buildWhatsAppMessage(orderUrl) {
  return `Hola naar! Aca esta la orden de mi pedido: ${orderUrl}`
}
