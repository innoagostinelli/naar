class Product < ApplicationRecord
  belongs_to :category
  has_many :variants, class_name: "ProductVariant", dependent: :destroy
  has_many :images,   class_name: "ProductImage",   dependent: :destroy

  enum :flag,   { sin_flag: 0, nuevo: 1, oferta: 2, bestseller: 3 }
  enum :status, { draft: 0, active: 1, archived: 2 }

  validates :name,     presence: true
  validates :price,    presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true

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
end
