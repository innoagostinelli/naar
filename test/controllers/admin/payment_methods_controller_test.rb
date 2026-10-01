require "test_helper"

class Admin::PaymentMethodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post admin_login_path, params: {
      username: admin_users(:naar_admin).username,
      password: "clave-de-test-123"
    }
    payment_methods(:zelle).update!(enabled: false)
  end

  test "deshabilitar el ultimo habilitado muestra alerta y no cambia nada" do
    method = payment_methods(:pago_movil)

    patch toggle_admin_payment_method_path(method)

    assert_redirected_to admin_payment_methods_path
    assert_equal PaymentMethod::LAST_ENABLED_MESSAGE, flash[:alert]
    assert method.reload.enabled?
  end

  test "eliminar el ultimo habilitado muestra alerta y no lo borra" do
    method = payment_methods(:pago_movil)

    delete admin_payment_method_path(method)

    assert_redirected_to admin_payment_methods_path
    assert_equal PaymentMethod::LAST_ENABLED_MESSAGE, flash[:alert]
    assert PaymentMethod.exists?(method.id)
  end

  test "destildar habilitado en el form de edicion del ultimo muestra el error" do
    method = payment_methods(:pago_movil)

    patch admin_payment_method_path(method), params: { payment_method: { enabled: "0" } }

    assert_response :unprocessable_entity
    assert_match "Debe haber al menos un método de pago habilitado", response.body
    assert method.reload.enabled?
  end
end
