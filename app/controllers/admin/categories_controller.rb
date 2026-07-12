class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [ :edit, :update, :destroy ]

  def index
    @q = Category.ransack(params[:q])
    categories = @q.result.includes(:products)

    @stats = [
      { value: categories.size,                                     label: "Total categorías" },
      { value: categories.count { |c| c.products.any? },   label: "Con productos" },
      { value: categories.count { |c| c.products.empty? }, label: "Sin productos" },
    ]

    case params[:has_products]
    when "yes" then categories = categories.select { |c| c.products.any? }
    when "no"  then categories = categories.select { |c| c.products.empty? }
    end

    @categories = categories
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: "Categoría creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Categoría actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_categories_path, notice: "Categoría eliminada."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :position, :image)
  end
end
