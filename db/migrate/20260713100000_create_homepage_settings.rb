class CreateHomepageSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :homepage_settings do |t|
      t.string :new_arrivals_eyebrow
      t.string :new_arrivals_title

      t.timestamps
    end
  end
end
