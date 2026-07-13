module ApplicationHelper
  include Pagy::Frontend

  def product_modal_data(product)
    image = product.images.first
    image_url = ->(img) { url_for(img.image.variant(resize_to_limit: [ 1000, 1300 ])) }

    swatches = product.swatches
    images_by_color = swatches.each_with_object({}) do |s, h|
      h[s[:name]] = product.images_for_color(s[:name]).select { |i| i.image.attached? }.map(&image_url)
    end

    generic_images = product.images.select { |i| i.color_name.blank? && i.image.attached? }.map(&image_url)

    {
      id: product.id,
      category: product.category.name,
      name: product.name,
      price: product.price.to_f,
      compareAtPrice: (product.compare_at_price.to_f if product.on_sale?),
      flag: product.flag_label,
      description: product.description.presence,
      sizes: product.sizes,
      swatches: swatches,
      image: (url_for(image.image.variant(resize_to_limit: [ 1000, 1300 ])) if image&.image&.attached?),
      images: generic_images,
      imagesByColor: images_by_color
    }
  end

  def locations_data
    State.order(:name).includes(:cities).map do |state|
      {
        id: state.id,
        name: state.name,
        cities: state.cities.order(:name).map { |city| { id: city.id, name: city.name } }
      }
    end
  end
end
