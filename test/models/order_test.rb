require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "pasar a pagada descuenta el stock de las variantes con match" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_m_negro)
    assert_equal 10, variant.stock

    order.update!(status: :pagada)

    assert_equal 8, variant.reload.stock
  end

  test "pasar de pagada a anulada restaura el stock" do
    order = orders(:pagada_order)
    variant = product_variants(:remera_l_negro)
    assert_equal 3, variant.stock

    order.update!(status: :anulada)

    assert_equal 5, variant.reload.stock
  end

  test "guardar sin cambiar el status no vuelve a descontar" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_m_negro)

    order.update!(status: :pagada)
    assert_equal 8, variant.reload.stock

    order.update!(customer_name: "Otro nombre")
    assert_equal 8, variant.reload.stock

    order.update!(status: :pagada)
    assert_equal 8, variant.reload.stock
  end

  test "rebote pagada -> anulada -> pagada deja el stock neto de un solo descuento" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_m_negro)

    order.update!(status: :pagada)
    assert_equal 8, variant.reload.stock

    order.update!(status: :anulada)
    assert_equal 10, variant.reload.stock

    order.update!(status: :pagada)
    assert_equal 8, variant.reload.stock
  end

  test "item sin match no bloquea el cambio de estado y queda registrado" do
    order = orders(:espera_pago_order)

    assert order.update(status: :pagada)
    assert order.pagada?

    unmatched = order.stock_adjustment_warnings
    assert_equal(
      [ order_items(:item_unmatched_no_product), order_items(:item_unmatched_bad_size) ].sort_by(&:id),
      unmatched.sort_by(&:id)
    )
  end

  test "sobreventa deja el stock en negativo sin lanzar excepcion" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_oversell)
    assert_equal 1, variant.stock

    assert_nothing_raised { order.update!(status: :pagada) }

    assert_equal(-4, variant.reload.stock)
  end

  test "variante con stock ilimitado (nil) no se modifica ni se reporta como no ajustada" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_unlimited)
    assert_nil variant.stock

    order.update!(status: :pagada)

    assert_nil variant.reload.stock
    refute_includes order.stock_adjustment_warnings, order_items(:item_unlimited)
  end

  test "transicion que no involucra pagada no ajusta stock" do
    order = orders(:espera_pago_order)
    variant = product_variants(:remera_m_negro)

    order.update!(status: :pendiente_contacto)

    assert_equal 10, variant.reload.stock
  end
end
