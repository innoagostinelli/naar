class ProductsController < ApplicationController
  # Fotos del modal de producto, pedidas on-demand al abrirlo (ver
  # ApplicationHelper#product_modal_data y product_modal_controller.js).
  def gallery
    product = Product.visible.includes(:variants, images: { image_attachment: :blob }).find(params[:id])
    render json: helpers.product_gallery_data(product)
  end
end
