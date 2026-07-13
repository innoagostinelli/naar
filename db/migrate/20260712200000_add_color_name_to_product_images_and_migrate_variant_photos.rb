class AddColorNameToProductImagesAndMigrateVariantPhotos < ActiveRecord::Migration[8.1]
  def up
    add_column :product_images, :color_name, :string

    # Migra la foto individual de cada variante (talla+color) a una ProductImage
    # etiquetada con ese color, reutilizando el mismo blob (sin volver a subir el archivo).
    # Las fotos genéricas existentes (sin color) no se tocan: siguen funcionando como
    # fallback para cualquier color sin fotos propias.
    ProductVariant.find_each do |variant|
      next unless variant.image.attached?

      min_position = ProductImage.where(product_id: variant.product_id).minimum(:position) || 1
      new_image = ProductImage.create!(
        product_id: variant.product_id,
        color_name: variant.color_name,
        position: min_position - 1
      )
      new_image.image.attach(variant.image.blob)
    end

    ActiveStorage::Attachment.where(record_type: "ProductVariant", name: "image").destroy_all
  end

  def down
    remove_column :product_images, :color_name
  end
end
