class OrdersController < ApplicationController
  def create
    items = items_params
    return render json: { errors: [ "El carrito está vacío" ] }, status: :unprocessable_entity if items.empty?

    order = Order.new(order_params.merge(total: 0))
    total = 0
    existing_product_ids = Product.where(id: items.map { |i| i[:id] }).ids.to_set

    items.each do |item|
      qty   = item[:qty].to_i
      price = item[:price].to_f
      total += qty * price

      order.order_items.build(
        # El carrito vive en localStorage del cliente y puede referenciar un producto
        # que ya no existe (editado/borrado desde el admin) — el pedido igual se guarda,
        # con el snapshot de nombre/precio/talla, solo sin el link al producto vivo.
        product_id: (item[:id].to_i if existing_product_ids.include?(item[:id].to_i)),
        name:       item[:name],
        size:       item[:size],
        color:      item[:color],
        qty:        qty,
        price:      price,
        image_url:  item[:image]
      )
    end
    order.total = total

    if order.save
      render json: { url: admin_order_url(order) }, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def items_params
    params.fetch(:items, []).map { |item| item.permit(:id, :name, :size, :color, :qty, :price, :image) }
  end

  def order_params
    params.permit(:customer_name, :customer_phone, :fulfillment_method, :address, :country, :state_id, :city_id)
  end
end
