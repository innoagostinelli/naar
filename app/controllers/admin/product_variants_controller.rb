class Admin::ProductVariantsController < Admin::BaseController
  before_action :set_product
  before_action :set_variant, only: [ :update, :destroy ]

  def create
    @variant = @product.variants.new(variant_params)
    if @variant.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: create_success_streams }
        format.html { redirect_to edit_admin_product_path(@product), notice: "Variante agregada." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: replace_new_row_stream, status: :unprocessable_entity }
        format.html { redirect_to edit_admin_product_path(@product), alert: @variant.errors.full_messages.to_sentence }
      end
    end
  end

  def update
    if @variant.update(variant_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: update_success_streams }
        format.html { redirect_to edit_admin_product_path(@product), notice: "Variante actualizada." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: replace_edit_row_stream, status: :unprocessable_entity }
        format.html { redirect_to edit_admin_product_path(@product), alert: @variant.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @variant.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: destroy_streams }
      format.html { redirect_to edit_admin_product_path(@product), notice: "Variante eliminada." }
    end
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

  # Un solo select mode arranca la fila "nueva" en el mismo modo que la
  # variante recién agregada, igual que en la carga inicial de la página.
  def next_new_variant_default_mode
    Product::NUMERIC_SIZES.include?(@variant.size) ? "numeric" : "alpha"
  end

  def create_success_streams
    [
      turbo_stream.append("variant_hidden_forms",
        partial: "admin/product_variants/row_form_tag", locals: { product: @product, variant: @variant }),
      turbo_stream.before("variant_form_row_new",
        partial: "admin/product_variants/row_pair", locals: { product: @product, variant: @variant }),
      turbo_stream.replace("variant_form_row_new",
        partial: "admin/product_variants/row_form",
        locals: { product: @product, variant: @product.variants.new, default_size_mode: next_new_variant_default_mode }),
      variants_count_stream
    ]
  end

  def replace_new_row_stream
    turbo_stream.replace("variant_form_row_new",
      partial: "admin/product_variants/row_form", locals: { product: @product, variant: @variant })
  end

  def update_success_streams
    [
      turbo_stream.replace("variant_row_#{@variant.id}",
        partial: "admin/product_variants/row", locals: { product: @product, variant: @variant }),
      turbo_stream.replace("variant_form_row_#{@variant.id}",
        partial: "admin/product_variants/row_form", locals: { product: @product, variant: @variant })
    ]
  end

  def replace_edit_row_stream
    turbo_stream.replace("variant_form_row_#{@variant.id}",
      partial: "admin/product_variants/row_form", locals: { product: @product, variant: @variant })
  end

  def destroy_streams
    [
      turbo_stream.remove("variant_row_#{@variant.id}"),
      turbo_stream.remove("variant_form_row_#{@variant.id}"),
      variants_count_stream
    ]
  end

  def variants_count_stream
    turbo_stream.replace("variantes_count", partial: "admin/product_variants/count", locals: { product: @product })
  end
end
