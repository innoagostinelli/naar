class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [ :edit, :update, :destroy ]

  def index
    @q = Product.ransack(params[:q])
    scope = @q.result.includes(:category).order(:category_id, :position)
    @pagy, @products = pagy(scope)

    @stats = [
      { value: Product.count,          label: "Total" },
      { value: Product.active.count,   label: "Activos" },
      { value: Product.nuevo.count,    label: "Nuevos" },
      { value: Product.oferta.count,   label: "En oferta" },
    ]
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to edit_admin_product_path(@product), notice: "Producto creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to edit_admin_product_path(@product), notice: "Producto actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: "Producto eliminado."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :compare_at_price,
      :category_id, :flag, :status, :position
    )
  end
end
