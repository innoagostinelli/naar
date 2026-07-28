class EmailSendLog < ApplicationRecord
  scope :today,      -> { where(created_at: Time.current.all_day) }
  scope :this_month, -> { where(created_at: Time.current.all_month) }
end
