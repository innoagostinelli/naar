namespace :catalog do
  desc "Borra todos los productos actuales (placeholder) antes de la carga inicial real"
  task purge_placeholders: :environment do
    product_ids = Product.pluck(:id)
    orders = Order.joins(:order_items).where(order_items: { product_id: product_ids }).distinct
    orders_count = orders.count
    orders.destroy_all

    count = Product.count
    Product.destroy_all
    puts "Borrados #{orders_count} pedidos vinculados a productos placeholder."
    puts "Borrados #{count} productos (con sus variantes/imagenes)."
  end

  desc "Importa categorias/productos/fotos desde el manifiesto generado a partir del sheet (uso: MANIFEST=path rake catalog:import_from_sheet)"
  task import_from_sheet: :environment do
    manifest_path = ENV.fetch("MANIFEST") { raise "Uso: MANIFEST=/ruta/a/manifest.json rake catalog:import_from_sheet" }
    entries = JSON.parse(File.read(manifest_path), symbolize_names: true)

    category_aliases = { "Sweaters" => "Suéteres" }

    created = 0
    failed = []

    entries.each do |entry|
      category_name = category_aliases.fetch(entry[:category_sheet], entry[:category_sheet])
      product_name  = entry[:product_name]

      begin
        category = Category.find_or_create_by!(name: category_name)

        product = Product.create!(
          name:     product_name,
          category: category,
          price:    1.00,
          status:   :draft
        )

        ProductVariant.create!(product: product, size: "Único", stock: 0)

        if entry[:image_path].present?
          image = ProductImage.create!(product: product)
          image.image.attach(
            io:           File.open(entry[:image_path]),
            filename:     File.basename(entry[:image_path]),
            content_type: entry[:mime_type]
          )
        end

        created += 1
      rescue => e
        failed << { row: entry[:row], product_name: product_name, error: e.message }
      end
    end

    puts "Creados: #{created}"
    puts "Fallidos: #{failed.size}"
    failed.each { |f| puts "  fila #{f[:row]} (#{f[:product_name]}): #{f[:error]}" }
  end
end
