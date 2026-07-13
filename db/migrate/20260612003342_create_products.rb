class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.integer :flag
      t.integer :status
      t.integer :position
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
