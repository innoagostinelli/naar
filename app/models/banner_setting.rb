class BannerSetting < ApplicationRecord
  include AttachmentValidatable

  has_one_attached :image
  has_one_attached :video

  validates_attachment :image,
    content_types: %w[image/jpeg image/png image/webp image/gif],
    max_size: 8.megabytes
  validates_attachment :video,
    content_types: %w[video/mp4 video/webm video/quicktime],
    max_size: 100.megabytes

  def self.instance
    first_or_create!
  end

  def media?
    image.attached? || video.attached?
  end
end
