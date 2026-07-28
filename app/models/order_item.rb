class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :name, presence: true
  validates :qty,   numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def subtotal
    qty * price
  end

  def matching_variant
    return nil if product_id.nil?

    ProductVariant.find_by(product_id: product_id, size: size, color_name: color)
  end

  # true si la variante que corresponde a este item existe, trackea stock,
  # y ese stock ya no alcanza para cubrir la cantidad pedida.
  def insufficient_stock?
    variant = matching_variant
    variant.present? && variant.stock.present? && variant.stock < qty
  end
end
