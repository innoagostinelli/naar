class Admin::OrdersController < Admin::BaseController
  before_action :set_order, only: [ :show, :update ]

  def index
    @orders = Order.order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where(fulfillment_method: params[:fulfillment_method]) if params[:fulfillment_method].present?
    @orders = @orders.where(created_at: date_range) if date_range

    @stats = {
      total_orders:       @orders.count,
      total_sales:        @orders.pagada.sum(:total),
      pendiente_contacto: @orders.pendiente_contacto.count,
      espera_pago:        @orders.espera_pago.count,
    }
  end

  def show
  end

  def update
    if @order.update(status_params)
      redirect_back fallback_location: admin_orders_path, notice: "Estado del pedido actualizado."
    else
      redirect_back fallback_location: admin_orders_path, alert: "No se pudo actualizar el estado."
    end
  end

  private

  def set_order
    @order = Order.find_by!(token: params[:id])
  end

  def status_params
    params.require(:order).permit(:status)
  end

  def date_range
    return nil if params[:date_from].blank? && params[:date_to].blank?

    from = params[:date_from].present? ? Date.parse(params[:date_from]).beginning_of_day : Time.zone.at(0)
    to   = params[:date_to].present?   ? Date.parse(params[:date_to]).end_of_day         : Time.zone.now.end_of_day
    from..to
  rescue ArgumentError
    nil
  end
end
