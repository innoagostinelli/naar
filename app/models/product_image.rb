class ProductImage < ApplicationRecord
  include AttachmentValidatable

  belongs_to :product
  has_one_attached :image

  validates_attachment :image,
    content_types: %w[image/jpeg image/png image/webp image/gif],
    max_size: 8.megabytes

  default_scope { order(:position) }
end
