class OrderStockAdjuster
  Result = Struct.new(:unmatched_items, keyword_init: true)

  def self.call(order:, from:, to:)
    new(order: order, from: from, to: to).call
  end

  def initialize(order:, from:, to:)
    @order = order
    @from = from
    @to = to
  end

  def call
    return Result.new(unmatched_items: []) unless action

    unmatched_items = []

    order.order_items.each do |item|
      variant = find_variant(item)

      if variant.nil?
        unmatched_items << item
        next
      end

      adjust_stock(variant, item.qty)
    end

    Result.new(unmatched_items: unmatched_items)
  end

  private

  attr_reader :order, :from, :to

  def action
    return :discount if to == "pagada" && from != "pagada"
    return :restore  if from == "pagada" && to == "anulada"

    nil
  end

  def find_variant(item)
    return nil if item.product_id.nil?

    ProductVariant.find_by(product_id: item.product_id, size: item.size, color_name: item.color)
  end

  def adjust_stock(variant, qty)
    return if variant.stock.nil?

    delta = action == :discount ? -qty : qty
    variant.update_columns(stock: variant.stock + delta)
  end
end
