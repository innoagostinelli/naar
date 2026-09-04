# Protección anti-bot para el checkout público (POST /orders).
# No toca /admin ni ninguna otra ruta — Manar puede seguir cargando
# inventario sin límite ahí.
Rails.application.config.middleware.use(Rack::Attack)

class Rack::Attack
  # Dos niveles: uno corto para frenar ráfagas (bot disparando rápido) y uno
  # más largo para el bot "lento" que espacía requests para evadir el primero.
  # Un comprador real no pasa de 1-2 pedidos por sesión, así que ninguno de
  # los dos límites lo afecta.
  throttle("orders/ip/burst", limit: 3, period: 1.minute) do |req|
    req.ip if req.path == "/orders" && req.post?
  end

  throttle("orders/ip/sustained", limit: 10, period: 1.hour) do |req|
    req.ip if req.path == "/orders" && req.post?
  end

  self.throttled_responder = lambda do |request|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { errors: [ "Demasiados pedidos en poco tiempo. Esperá unos minutos e intentá de nuevo." ] }.to_json ]
    ]
  end
end
