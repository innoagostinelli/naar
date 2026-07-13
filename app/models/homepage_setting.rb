class HomepageSetting < ApplicationRecord
  DEFAULTS = {
    new_arrivals_eyebrow: "Recién llegado · Mayo 2026",
    new_arrivals_title:   "Lo nuevo en Naar.",
  }.freeze

  validates :new_arrivals_eyebrow, :new_arrivals_title, presence: true

  def self.instance
    first_or_create!(DEFAULTS)
  end
end
