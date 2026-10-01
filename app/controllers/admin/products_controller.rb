class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: [ :edit, :update, :destroy, :restore ]

  def index
    @q = Product.not_deleted.ransack(params[:q])
    scope = @q.result.includes(:category).order(:category_id, :position)
    @pagy, @products = pagy(scope)

    @stats = [
      { value: Product.not_deleted.count, label: "Total" },
      { value: Product.active.count,      label: "Activos" },
      { value: Product.nuevo.count,       label: "Nuevos" },
      { value: Product.oferta.count,      label: "En oferta" },
    ]
  end

  def deleted
    @q = Product.deleted.ransack(params[:q])
    scope = @q.result.includes(:category).order(:category_id, :position)
    @pagy, @products = pagy(scope)
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
    @product.update(status: :deleted)
    redirect_to admin_products_path, notice: "Producto eliminado. Puedes restaurarlo desde Productos eliminados."
  end

  def restore
    @product.update(status: :draft)
    redirect_to deleted_admin_products_path, notice: "Producto restaurado a borrador."
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
