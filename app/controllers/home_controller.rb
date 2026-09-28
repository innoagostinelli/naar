class HomeController < ApplicationController
  def index
    @categories = Category.joins(:products)
                          .where(products: { status: :active })
                          .distinct
                          .order(:position)
                          .includes(image_attachment: :blob)
    @nuevos     = Product.active.nuevo.order(:position).limit(8).with_card_data
    @products_by_category = Product.active.order(:position).with_card_data.group_by(&:category_id)
    @reels      = Reel.all
    @faqs       = Faq.all
    @homepage_setting = HomepageSetting.instance
    @banner_setting   = BannerSetting.instance
  end
end
