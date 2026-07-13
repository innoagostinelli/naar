class HomeController < ApplicationController
  def index
    @categories = Category.joins(:products)
                          .where(products: { status: :active })
                          .distinct
                          .order(:position)
                          .includes(image_attachment: :blob)
    @nuevos     = Product.active.nuevo.order(:position).limit(8).includes(:images, :variants)
    @reels      = Reel.all
    @faqs       = Faq.all
    @homepage_setting = HomepageSetting.instance
  end
end
