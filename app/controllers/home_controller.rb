class HomeController < ApplicationController
  def index
    @categories = Category.joins(:products)
                          .where(products: { status: :active })
                          .distinct
                          .order(:position)
    @nuevos     = Product.active.nuevo.order(:position).limit(8)
    @reels      = Reel.all
    @faqs       = Faq.all
  end
end
