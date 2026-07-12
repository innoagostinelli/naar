class Admin::HomepageSettingsController < Admin::BaseController
  def edit
    @homepage_setting = HomepageSetting.instance
  end

  def update
    @homepage_setting = HomepageSetting.instance
    if @homepage_setting.update(homepage_setting_params)
      redirect_to edit_admin_homepage_setting_path, notice: "Textos actualizados."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def homepage_setting_params
    params.require(:homepage_setting).permit(:new_arrivals_eyebrow, :new_arrivals_title)
  end
end
