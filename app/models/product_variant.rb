class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items,  dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :product, presence: true
  validates :stock,   numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def in_stock?
    stock.nil? || stock > 0
  end

  def display_name
    parts = [ product.name ]
    parts << size       if size.present?
    parts << color_name if color_name.present?
    parts.join(" — ")
  end
end
