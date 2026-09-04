class Admin::SessionsController < ApplicationController
  layout "admin_login"

  def new
    redirect_to admin_root_path if admin_signed_in?
  end

  def create
    admin_user = AdminUser.find_by(username: params[:username].to_s.strip.downcase)

    if admin_user&.authenticate(params[:password])
      reset_session # evita session fixation
      session[:admin_user_id] = admin_user.id
      redirect_to (session.delete(:admin_return_to) || admin_root_path)
    else
      flash.now[:alert] = "Usuario o contraseña incorrectos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to admin_login_path, notice: "Sesión cerrada."
  end

  private

  def admin_signed_in?
    session[:admin_user_id].present?
  end
end
