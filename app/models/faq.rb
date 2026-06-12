class Faq < ApplicationRecord
  validates :question, :answer, presence: true
  default_scope { order(:position) }
end
