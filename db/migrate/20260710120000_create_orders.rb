class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: true, foreign_key: true
      t.string :name, null: false
      t.string :size
      t.string :color
      t.integer :qty, null: false, default: 1
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :image_url

      t.timestamps
    end
  end
end
