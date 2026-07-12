class Product < ApplicationRecord
  belongs_to :category
  has_many :variants, class_name: "ProductVariant", dependent: :destroy
  has_many :images,   class_name: "ProductImage",   dependent: :destroy

  SIZE_ORDER = %w[XS S M L XL XXL].freeze

  enum :flag,   { sin_flag: 0, nuevo: 1, oferta: 2, bestseller: 3 }
  enum :status, { draft: 0, active: 1, archived: 2 }

  validates :name,     presence: true
  validates :price,    presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true

  before_save :sync_flag_with_compare_at_price

  scope :visible,   -> { where(status: :active).order(:position) }
  scope :nuevos,    -> { active.where(flag: :nuevo) }
  scope :en_oferta, -> { active.where(flag: :oferta) }

  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end

  def flag_label
    { "nuevo" => "NUEVO", "oferta" => "OFERTA", "bestseller" => "BESTSELLER" }[flag]
  end

  def swatches
    variants.select(:color_hex, :color_name).distinct.map { |v| { hex: v.color_hex, name: v.color_name } }
  end

  def sizes
    variants.map(&:size).compact.uniq.sort_by { |s| SIZE_ORDER.index(s) || 99 }
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name category_id flag status]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def images_for_color(color_name)
    specific = images.select { |i| i.color_name == color_name }
    generic  = images.select { |i| i.color_name.blank? }
    specific + generic
  end

  # Galería para la card (sin contexto de color): una foto representativa
  # de cada color + las genéricas, para que nunca quede sin ninguna imagen.
  def cover_gallery
    one_per_color = images.select { |i| i.color_name.present? }
                          .group_by(&:color_name)
                          .map { |_, imgs| imgs.first }
    generic = images.select { |i| i.color_name.blank? }
    one_per_color + generic
  end

  private

  def sync_flag_with_compare_at_price
    return unless compare_at_price_changed?

    if compare_at_price.present? && compare_at_price > 0
      self.flag = :oferta
    elsif compare_at_price_was.present? && compare_at_price_was > 0
      self.flag = :sin_flag
    end
  end
end
