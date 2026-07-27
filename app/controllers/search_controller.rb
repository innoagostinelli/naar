class SearchController < ApplicationController
  PREVIEW_LIMIT = 8

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      needle   = normalize(@query)
      matches  = Product.visible.includes(:images, :variants, :category)
                         .select { |p| normalize(p.name).include?(needle) || normalize(p.description.to_s).include?(needle) }
      @total    = matches.size
      @products = turbo_frame_request? ? matches.first(PREVIEW_LIMIT) : matches
    else
      @total    = 0
      @products = Product.none
    end
  end

  private

  # Ignora acentos y mayúsculas para que "salome" encuentre "Salomé" (y viceversa).
  def normalize(text)
    I18n.transliterate(text.to_s).downcase
  end
end
