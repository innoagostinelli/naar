class Admin::BannerSettingsController < Admin::BaseController
  def edit
    @banner_setting = BannerSetting.instance
  end

  def update
    @banner_setting = BannerSetting.instance
    @banner_setting.image.purge if params.dig(:banner_setting, :remove_image) == "1"
    @banner_setting.video.purge if params.dig(:banner_setting, :remove_video) == "1"

    if @banner_setting.update(banner_setting_params)
      redirect_to edit_admin_banner_setting_path, notice: "Banner actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def banner_setting_params
    params.require(:banner_setting).permit(:active, :image, :video)
  end
end
