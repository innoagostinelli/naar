class HomeController < ApplicationController
  def index
    @categories  = Category.all
    @nuevos      = Product.active.nuevo.order(:position).limit(8)
    @reels       = Reel.all
    @faqs        = Faq.all
    @catalog     = Category.includes(products: :variants)
                           .where(products: { status: :active })
                           .where.not(products: { id: nil })
  end
end
