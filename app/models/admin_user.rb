class AdminUser < ApplicationRecord
  has_secure_password

  before_validation :normalize_username

  validates :username, presence: true, uniqueness: true

  private

  def normalize_username
    self.username = username.to_s.strip.downcase
  end
end
