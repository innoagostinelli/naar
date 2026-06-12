class ProductImage < ApplicationRecord
  belongs_to :product
  has_one_attached :image

  default_scope { order(:position) }
end
