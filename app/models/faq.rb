class Faq < ApplicationRecord
  validates :question, :answer, presence: true
  default_scope { order(:position) }

  def self.ransackable_attributes(auth_object = nil)
    %w[question answer]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
