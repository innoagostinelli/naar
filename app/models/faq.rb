class Faq < ApplicationRecord
  include AccentInsensitiveSearch

  validates :question, :answer, presence: true
  default_scope { order(:position) }

  accent_insensitive_ransacker :question
  accent_insensitive_ransacker :answer

  def self.ransackable_attributes(auth_object = nil)
    %w[question answer question_unaccent answer_unaccent]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
