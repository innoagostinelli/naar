class Reel < ApplicationRecord
  has_one_attached :video

  validates :label, presence: true
  default_scope { order(:position) }
end
