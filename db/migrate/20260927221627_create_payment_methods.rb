class CreatePaymentMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_methods do |t|
      t.string  :name,     null: false
      t.boolean :enabled,  null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        [ "Pago móvil", "Efectivo", "Paypal", "Zelle", "Binance" ].each_with_index do |name, i|
          # `TRUE` como keyword SQL (no vía `quote(true)`): en SQLite, un boolean
          # insertado como texto ("true"/"t") queda con afinidad TEXT en vez de
          # NUMERIC, y `WHERE enabled = 1` (lo que genera `where(enabled: true)`)
          # nunca matchea. El keyword `TRUE` sí lo normaliza a entero 1.
          execute <<~SQL
            INSERT INTO payment_methods (name, enabled, position, created_at, updated_at)
            VALUES (#{quote(name)}, TRUE, #{i}, #{quote(Time.current)}, #{quote(Time.current)})
          SQL
        end
      end
    end
  end
end
