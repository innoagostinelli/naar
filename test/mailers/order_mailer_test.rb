require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  test "el aviso de nueva orden incluye el metodo de pago" do
    order = orders(:espera_pago_order)
    order.update_column(:payment_method, "Zelle")

    mail = OrderMailer.new_order_notification(order)

    assert_match "Método de pago: Zelle", mail.text_part.body.to_s
    assert_match "Zelle", mail.html_part.body.to_s
  end
end
