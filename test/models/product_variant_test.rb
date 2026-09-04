require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "no permite dos variantes con la misma talla y color para el mismo producto" do
    original = product_variants(:remera_m_negro)
    dup = original.product.variants.build(size: original.size, color_name: original.color_name, stock: 1)

    assert_not dup.valid?
    assert_includes dup.errors[:size], "ya existe una variante con esta talla y color para este producto"
  end

  test "permite la misma talla en un color distinto" do
    original = product_variants(:remera_m_negro)
    other_color = original.product.variants.build(size: original.size, color_name: "Verde", stock: 1)

    assert other_color.valid?
  end

  test "permite el mismo color en una talla distinta" do
    original = product_variants(:remera_m_negro)
    other_size = original.product.variants.build(size: "XXL", color_name: original.color_name, stock: 1)

    assert other_size.valid?
  end
end
