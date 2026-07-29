class CreateBannerSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :banner_settings do |t|
      t.boolean :active, null: false, default: false

      t.timestamps
    end
  end
end
