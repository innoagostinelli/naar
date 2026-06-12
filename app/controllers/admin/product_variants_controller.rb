class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product
  before_action :set_variant, only: [ :edit, :update, :destroy ]

  def new
    @variant = @product.variants.new
  end

  def create
    @variant = @product.variants.new(variant_params)
    if @variant.save
      redirect_to edit_admin_product_path(@product), notice: "Variante agregada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @variant.update(variant_params)
      redirect_to edit_admin_product_path(@product), notice: "Variante actualizada."
    else
      render :edit, status: :unprocessable_entity
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
