class Category < ApplicationRecord
  include AttachmentValidatable
  include AccentInsensitiveSearch

  has_many :products, -> { order(:position) }, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates_attachment :image,
    content_types: %w[image/jpeg image/png image/webp image/gif],
    max_size: 8.megabytes

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  default_scope { order(:position) }

  accent_insensitive_ransacker :name

  def self.ransackable_attributes(auth_object = nil)
    %w[name name_unaccent]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[products]
  end

  private

  def generate_slug
    self.slug = self.class.strip_accents(name).strip
                    .gsub(/[^a-z0-9\s-]/, "").gsub(/\s+/, "-")
  end
end
