require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    post admin_login_path, params: {
      username: admin_users(:naar_admin).username,
      password: "clave-de-test-123"
    }
  end

  test "marcar como pagada descuenta el stock en base de datos" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_m_negro)
    assert_equal 10, variant.stock

    patch admin_order_path(order), params: { order: { status: "pagada" } }

    assert_redirected_to admin_orders_path
    assert_equal "pagada", order.reload.status
    assert_equal 8, variant.reload.stock
  end

  test "items sin match agregan aviso al mensaje de notificacion" do
    order = orders(:espera_pago_order)

    patch admin_order_path(order), params: { order: { status: "pagada" } }

    assert_match "Atención: no se pudo ajustar el stock", flash[:notice]
    assert_match "Producto Borrado", flash[:notice]
  end
end
