class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product
  before_action :set_variant, only: [ :update, :destroy ]

  def create
    @variant = @product.variants.new(variant_params)
    if @variant.save
      redirect_to edit_admin_product_path(@product), notice: "Variante agregada."
    else
      redirect_to edit_admin_product_path(@product), alert: @variant.errors.full_messages.to_sentence
    end
  end

  def update
    if @variant.update(variant_params)
      redirect_to edit_admin_product_path(@product), notice: "Variante actualizada."
    else
      redirect_to edit_admin_product_path(@product), alert: @variant.errors.full_messages.to_sentence
    end
  end

  def destroy
    @variant.destroy
    redirect_to edit_admin_product_path(@product), notice: "Variante eliminada."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = @product.variants.find(params[:id])
  end

  def variant_params
    params.require(:product_variant).permit(:size, :color_name, :color_hex, :sku, :stock)
  end
end
