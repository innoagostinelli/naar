class Admin::DashboardController < Admin::BaseController
  def index
    @total_products  = Product.count
    @active_products = Product.active.count
    @oferta_products = Product.en_oferta.count
    @total_cats      = Category.count
    @total_faqs      = Faq.count
    @total_reels     = Reel.count
    @storage_usage   = StorageUsageService.call
  end
end
