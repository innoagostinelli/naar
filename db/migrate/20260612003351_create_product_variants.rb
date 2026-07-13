class CreateProductVariants < ActiveRecord::Migration[8.1]
  def change
    create_table :product_variants do |t|
      t.references :product, null: false, foreign_key: true
      t.string :size
      t.string :color_name
      t.string :color_hex
      t.integer :stock
      t.string :sku

      t.timestamps
    end
  end
end
