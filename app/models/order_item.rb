class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :name, presence: true
  validates :qty,   numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  def subtotal
    qty * price
  end
end
