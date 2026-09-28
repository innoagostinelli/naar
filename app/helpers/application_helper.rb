module ApplicationHelper
  include Pagy::Frontend

  # Datos del modal que viajan en el data-product de cada card. Sin URLs de
  # imágenes: generar las variantes firmadas de toda la galería de cada card
  # era lo que hacía lenta la home. Las fotos las pide el modal al abrirse
  # (galleryUrl -> ProductsController#gallery -> product_gallery_data).
  def product_modal_data(product)
    {
      id: product.id,
      category: product.category.name,
      name: product.name,
      price: product.price.to_f,
      compareAtPrice: (product.compare_at_price.to_f if product.on_sale?),
      flag: product.flag_label,
      description: product.description.presence,
      sizes: product.sizes,
      swatches: product.swatches,
      variants: product.variants.map { |v| { size: v.size, color: v.color_name, stock: v.stock } },
      galleryUrl: product_gallery_path(product)
    }
  end

  # Cada foto va como { id:, url: } para que el modal pueda arrancar por la
  # misma foto que se estaba viendo en la card (data-image-id).
  def product_gallery_data(product)
    image = product.images.first
    slide = ->(img) { { id: img.id, url: url_for(img.image.variant(resize_to_limit: [ 1000, 1300 ])) } }

    images_by_color = product.swatches.each_with_object({}) do |s, h|
      h[s[:name]] = product.images_for_color(s[:name]).select { |i| i.image.attached? }.map(&slide)
    end

    generic_images = product.images.select { |i| i.color_name.blank? && i.image.attached? }.map(&slide)

    {
      image: (slide.call(image) if image&.image&.attached?),
      images: generic_images,
      imagesByColor: images_by_color
    }
  end

  def locations_data
    # Un solo JOIN ordenado; state.cities.order(...) acá haría una query por estado.
    State.eager_load(:cities).order("states.name", "cities.name").map do |state|
      {
        id: state.id,
        name: state.name,
        cities: state.cities.map { |city| { id: city.id, name: city.name } }
      }
    end
  end
end
