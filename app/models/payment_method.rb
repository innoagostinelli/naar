class PaymentMethod < ApplicationRecord
  LAST_ENABLED_MESSAGE = "Debe haber al menos un método de pago habilitado: el checkout no puede quedarse sin opciones."

  default_scope { order(:position) }
  scope :enabled, -> { where(enabled: true) }

  validates :name, presence: true, uniqueness: true
  validate :keeps_one_enabled, on: :update
  before_destroy :ensure_not_last_enabled

  def last_enabled?
    enabled_in_database && PaymentMethod.enabled.where.not(id: id).none?
  end

  private

  def keeps_one_enabled
    errors.add(:base, LAST_ENABLED_MESSAGE) if will_save_change_to_enabled? && !enabled? && last_enabled?
  end

  def ensure_not_last_enabled
    return unless last_enabled?

    errors.add(:base, LAST_ENABLED_MESSAGE)
    throw :abort
  end
end
