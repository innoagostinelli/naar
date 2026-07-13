class Order < ApplicationRecord
  has_secure_token

  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items

  belongs_to :state, optional: true
  belongs_to :city, optional: true

  enum :fulfillment_method, { delivery: 0, pickup: 1 }
  enum :status, { pendiente_contacto: 0, espera_pago: 1, pagada: 2, anulada: 3 }

  STATUS_LABELS = {
    "pendiente_contacto" => "Pendiente por primer contacto",
    "espera_pago"        => "Espera por el pago",
    "pagada"             => "Pagada",
    "anulada"            => "Anulada",
  }.freeze

  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validates :customer_name, presence: true
  validates :customer_phone, presence: true
  validates :fulfillment_method, presence: true
  validates :address, presence: true, if: :delivery?
  validates :state, presence: true, if: :delivery?
  validates :city, presence: true, if: :delivery?
  validate :city_belongs_to_state, if: :delivery?

  def to_param
    token
  end

  def status_label
    STATUS_LABELS[status]
  end

  private

  def city_belongs_to_state
    errors.add(:city, "no pertenece al estado seleccionado") if city && state && city.state_id != state.id
  end
end
