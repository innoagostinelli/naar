class Category < ApplicationRecord
  has_many :products, -> { order(:position) }, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  default_scope { order(:position) }

  private

  def generate_slug
    self.slug = name.downcase.strip
                    .gsub(/[áàäâ]/, "a").gsub(/[éèëê]/, "e")
                    .gsub(/[íìïî]/, "i").gsub(/[óòöô]/, "o")
                    .gsub(/[úùüû]/, "u").gsub("ñ", "n")
                    .gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-")
  end
end
