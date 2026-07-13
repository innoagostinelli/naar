class AddCustomerDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :customer_name, :string
    add_column :orders, :fulfillment_method, :integer
    add_column :orders, :address, :text
  end
end
