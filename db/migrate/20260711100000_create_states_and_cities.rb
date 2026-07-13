class CreateStatesAndCities < ActiveRecord::Migration[8.1]
  def change
    create_table :states do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :states, :name, unique: true

    create_table :cities do |t|
      t.string :name, null: false
      t.references :state, null: false, foreign_key: true
      t.timestamps
    end
    add_index :cities, [ :state_id, :name ], unique: true
  end
end
