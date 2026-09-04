class Admin::PasswordsController < Admin::BaseController
  def edit
  end

  def update
    if current_admin_user.authenticate(params[:current_password])
      if current_admin_user.update(password_params)
        redirect_to admin_root_path, notice: "Contraseña actualizada."
      else
        flash.now[:alert] = current_admin_user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "La contraseña actual no es correcta."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:admin_user).permit(:password, :password_confirmation)
  end
end
