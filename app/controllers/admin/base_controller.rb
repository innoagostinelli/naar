class Admin::BaseController < ApplicationController
  include Pagy::Backend
  # Fija ActiveStorage::Current.url_options para poder pedir URLs directas de
  # archivos (ej. miniaturas ya procesadas) también con el servicio Disk de dev.
  include ActiveStorage::SetCurrent

  before_action :require_admin
  layout "admin"
  helper_method :current_admin_user, :admin_signed_in?

  private

  def current_admin_user
    @current_admin_user ||= AdminUser.find_by(id: session[:admin_user_id])
  end

  def admin_signed_in?
    current_admin_user.present?
  end

  def require_admin
    return if admin_signed_in?

    session[:admin_return_to] = request.fullpath if request.get?
    redirect_to admin_login_path, alert: "Inicia sesión para continuar."
  end
end
