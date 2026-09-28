class SitemapsController < ApplicationController
  # Por ahora solo la home; las páginas de productos y categorías se suman
  # cuando existan (un sitemap con URLs que dan 404 perjudica).
  def show
    @home_lastmod = Product.visible.maximum(:updated_at)
    expires_in 1.hour, public: true
  end
end
