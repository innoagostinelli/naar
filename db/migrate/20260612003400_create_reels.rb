class CreateReels < ActiveRecord::Migration[8.1]
  def change
    create_table :reels do |t|
      t.string :tag
      t.string :label
      t.integer :position

      t.timestamps
    end
  end
end
