class PaymentMethod < ApplicationRecord
  default_scope { order(:position) }
  scope :enabled, -> { where(enabled: true) }

  validates :name, presence: true, uniqueness: true
end
