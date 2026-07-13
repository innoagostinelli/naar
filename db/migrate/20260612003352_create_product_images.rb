class CreateProductImages < ActiveRecord::Migration[8.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :position
      t.string :alt

      t.timestamps
    end
  end
end
