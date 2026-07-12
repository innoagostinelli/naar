export function showToast(message, duration = 4000) {
  const el = document.createElement("div")
  el.className = "naar-toast"
  el.setAttribute("role", "status")
  el.textContent = message
  document.body.appendChild(el)

  requestAnimationFrame(() => el.classList.add("is-visible"))

  setTimeout(() => {
    el.classList.remove("is-visible")
    el.addEventListener("transitionend", () => el.remove(), { once: true })
  }, duration)
}
