class Order < ApplicationRecord
  has_secure_token

  attr_accessor :stock_adjustment_warnings

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

  after_update :adjust_stock_for_status_change, if: :saved_change_to_status?
  # _commit (no after_create): el job de email corre en otro hilo (Async
  # adapter) y busca la orden por GlobalID — si se encola antes de que la
  # transacción del create haga commit, el hilo del job no la encuentra
  # todavía (ActiveJob::DeserializationError) y el mail nunca sale.
  after_create_commit :send_new_order_notification

  def to_param
    token
  end

  def status_label
    STATUS_LABELS[status]
  end

  # true si la orden todavía no se pagó (el stock no se reservó) y alguno de
  # sus items ya no tiene suficiente stock disponible en este momento.
  def stock_conflict?
    return false unless pendiente_contacto? || espera_pago?

    order_items.any?(&:insufficient_stock?)
  end

  private

  def send_new_order_notification
    OrderMailer.new_order_notification(self).deliver_later
  end

  def city_belongs_to_state
    errors.add(:city, "no pertenece al estado seleccionado") if city && state && city.state_id != state.id
  end

  def adjust_stock_for_status_change
    from, to = saved_change_to_status
    result = OrderStockAdjuster.call(order: self, from: from, to: to)
    self.stock_adjustment_warnings = result.unmatched_items

    result.unmatched_items.each do |item|
      Rails.logger.warn(
        "OrderStockAdjuster: no se pudo ajustar stock del item ##{item.id} " \
        "(#{item.name} / #{item.size} / #{item.color}) en la orden #{token}"
      )
    end
  end
end
