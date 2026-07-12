class AddLocationToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :country, :string, default: "Venezuela", null: false
    add_reference :orders, :state, foreign_key: true
    add_reference :orders, :city, foreign_key: true
  end
end
