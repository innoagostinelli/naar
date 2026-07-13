class Admin::ProductImagesController < Admin::BaseController
  before_action :set_product
  before_action :set_image, only: [ :edit, :update, :destroy ]

  def new
    @image = @product.images.new
  end

  def create
    @image = @product.images.new(image_params)
    if @image.save
      redirect_to edit_admin_product_path(@product), notice: "Imagen agregada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @image.update(image_params)
      redirect_to edit_admin_product_path(@product), notice: "Imagen actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy
    redirect_to edit_admin_product_path(@product), notice: "Imagen eliminada."
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_image
    @image = @product.images.find(params[:id])
  end

  def image_params
    params.require(:product_image).permit(:image, :alt, :position, :color_name)
  end
end
