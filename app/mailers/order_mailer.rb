class OrderMailer < ApplicationMailer
  # TODO: cambiar a "manarnassernasser@gmail.com" antes de ir a producción real —
  # por ahora apunta al correo secundario de Inno mientras se prueba el flujo.
  RECIPIENT_EMAIL = "innoagostinelli@gmail.com"

  def new_order_notification(order)
    @order = order
    mail(to: RECIPIENT_EMAIL, subject: "Nueva orden de compra en NaarByManar")
  end
end
