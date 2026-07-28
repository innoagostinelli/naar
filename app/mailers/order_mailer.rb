class OrderMailer < ApplicationMailer
  RECIPIENT_EMAIL = "manarnassernasser@gmail.com"

  def new_order_notification(order)
    @order = order
    mail(to: RECIPIENT_EMAIL, subject: "Nueva orden de compra en NaarByManar")
  end
end
