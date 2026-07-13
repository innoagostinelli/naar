class Reel < ApplicationRecord
  include AttachmentValidatable

  has_one_attached :video

  validates :label, presence: true
  validates_attachment :video,
    content_types: %w[video/mp4 video/webm video/quicktime],
    max_size: 100.megabytes

  default_scope { order(:position) }

  def self.ransackable_attributes(auth_object = nil)
    %w[tag label]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
