require "test_helper"

class PaymentMethodTest < ActiveSupport::TestCase
  setup { payment_methods(:zelle).update!(enabled: false) }

  test "no se puede deshabilitar el ultimo metodo habilitado" do
    method = payment_methods(:pago_movil)

    assert_not method.update(enabled: false)
    assert_includes method.errors[:base], PaymentMethod::LAST_ENABLED_MESSAGE
    assert method.reload.enabled?
  end

  test "no se puede eliminar el ultimo metodo habilitado" do
    method = payment_methods(:pago_movil)

    assert_not method.destroy
    assert_includes method.errors[:base], PaymentMethod::LAST_ENABLED_MESSAGE
    assert PaymentMethod.exists?(method.id)
  end

  test "se puede deshabilitar o eliminar si queda otro habilitado" do
    payment_methods(:zelle).update!(enabled: true)

    assert payment_methods(:pago_movil).update(enabled: false)
    assert payment_methods(:pago_movil).destroy
  end

  test "se puede eliminar un metodo deshabilitado aunque solo quede uno habilitado" do
    assert payment_methods(:paypal).destroy
  end

  test "editar el nombre del ultimo habilitado no lo bloquea" do
    assert payment_methods(:pago_movil).update(name: "Pago Móvil")
  end
end
