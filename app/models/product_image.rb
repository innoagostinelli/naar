class ProductImage < ApplicationRecord
  include AttachmentValidatable

  belongs_to :product
  # :thumb = 56px @2x. Misma transformación que usaba la galería del edit, así
  # reutiliza las variantes ya generadas. `preprocessed` la genera en un job al
  # subir la foto, para que el listado del admin no tenga que procesarla.
  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 112, 112 ], preprocessed: true
  end

  validates_attachment :image,
    content_types: %w[image/jpeg image/png image/webp image/gif],
    max_size: 8.megabytes

  default_scope { order(:position) }
end
