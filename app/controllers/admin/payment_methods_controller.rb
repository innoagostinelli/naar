class Admin::PaymentMethodsController < Admin::BaseController
  before_action :set_payment_method, only: [ :edit, :update, :destroy, :toggle ]

  def index
    @payment_methods = PaymentMethod.all
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)
    if @payment_method.save
      redirect_to admin_payment_methods_path, notice: "Método de pago creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @payment_method.update(payment_method_params)
      redirect_to admin_payment_methods_path, notice: "Método de pago actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @payment_method.destroy
    redirect_to admin_payment_methods_path, notice: "Método de pago eliminado."
  end

  def toggle
    @payment_method.update(enabled: !@payment_method.enabled)
    state = @payment_method.enabled? ? "habilitado" : "deshabilitado"
    redirect_to admin_payment_methods_path, notice: "Método de pago #{state}."
  end

  private

  def set_payment_method
    @payment_method = PaymentMethod.find(params[:id])
  end

  def payment_method_params
    params.require(:payment_method).permit(:name, :position, :enabled)
  end
end
