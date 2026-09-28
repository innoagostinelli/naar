# Catálogo de prueba para desarrollo, con fotos generadas localmente (libvips).
# Replica el volumen de producción (~132 productos, ~250 fotos de ~2MB) para
# medir performance y trabajar SEO sin traer datos ni archivos de prod/R2.
#
#   bin/rails dev:demo_catalog
#
# BORRA el catálogo actual de dev (categorías, productos, variantes, fotos) y
# los pedidos de prueba que lo referencian. Antes deja un backup consistente de
# la base en storage/. Reels, FAQs, settings y estados/ciudades no se tocan.
# Los archivos viejos en storage/ no se borran, para que el backup siga sirviendo.
namespace :dev do
  desc "Reemplaza el catálogo de dev por uno de prueba con fotos generadas (solo development)"
  task demo_catalog: :environment do
    abort "dev:demo_catalog solo corre en development (Rails.env=#{Rails.env})" unless Rails.env.development?

    DemoCatalog.new.run
  end
end

class DemoCatalog
  CATEGORIES = {
    "Vestidos"   => [ "Vestido midi", "Vestido largo", "Vestido corto", "Vestido camisero", "Vestido lencero" ],
    "Tops"       => [ "Crop top", "Blusa", "Top off-shoulder", "Top halter", "Camisa" ],
    "Sets"       => [ "Set lino", "Set tejido", "Set satinado" ],
    "Faldas"     => [ "Falda midi", "Falda larga", "Minifalda", "Falda plisada" ],
    "Pantalones" => [ "Pantalón lino", "Pantalón palazzo", "Jean mom", "Jean acampanado", "Pantalón cargo" ],
    "Bodys"      => [ "Body satinado", "Body encaje", "Body manga larga" ],
    "Suéteres"   => [ "Suéter punto", "Cárdigan", "Suéter oversize" ],
    "Rompers"    => [ "Romper", "Enterizo" ],
    "Shorts"     => [ "Short denim", "Short lino", "Short sastre" ],
    "Chaquetas"  => [ "Chaqueta denim", "Blazer", "Chaqueta efecto cuero" ],
    "Accesorios" => [ "Cartera", "Cinturón", "Pañuelo" ],
    "Descuentos" => [ "Top básico", "Falda básica" ]
  }.freeze

  NAMES = %w[Aurora Lucía Valentina Camila Renata Andrea Antonia Daniela Sofía Isabella
             Mariana Gabriela Victoria Paula Elena Carolina Manuela Julieta Emilia Salomé].freeze

  COLORS = {
    "Negro" => "#211218", "Burgundy" => "#820045", "Crema" => "#FBF6E9", "Amarillo" => "#F2E651",
    "Malva" => "#5A4751", "Rosa" => "#A52B6A", "Blanco" => "#FFFFFF", "Azul denim" => "#4A6A8A",
    "Verde oliva" => "#6B6B3A", "Beige" => "#D8C3A5", "Terracota" => "#B5543A", "Celeste" => "#A9C8E0"
  }.freeze

  STATUSES = ([ :active ] * 110 + [ :draft ] * 14 + [ :deleted ] * 8).freeze
  PHOTO_SIZE = [ 3000, 4000 ].freeze # como las fotos de celular de prod (~2MB en JPEG)

  def initialize
    @rng = Random.new(42) # determinístico: mismo catálogo cada vez
  end

  def run
    require "vips"
    backup_database
    wipe_catalog
    categories = create_categories
    create_products(categories)

    puts "Listo: #{Category.count} categorías, #{Product.count} productos " \
         "(#{Product.active.count} activos), #{ProductVariant.count} variantes, #{ProductImage.count} fotos."
  end

  private

  def backup_database
    path = Rails.root.join("storage", "development.sqlite3.bak-#{Time.current.strftime('%Y%m%d%H%M%S')}")
    ActiveRecord::Base.connection.execute("VACUUM INTO #{ActiveRecord::Base.connection.quote(path.to_s)}")
    puts "Backup de la base: #{path}"
  end

  def wipe_catalog
    ActiveRecord::Base.transaction do
      blob_ids        = ActiveStorage::Attachment.where(record_type: %w[Category ProductImage]).pluck(:blob_id)
      variant_ids     = ActiveStorage::VariantRecord.where(blob_id: blob_ids).pluck(:id)
      variant_blob_ids = ActiveStorage::Attachment.where(record_type: "ActiveStorage::VariantRecord", record_id: variant_ids).pluck(:blob_id)
      all_blob_ids    = blob_ids + variant_blob_ids

      ActiveStorage::Attachment.where(blob_id: all_blob_ids).delete_all
      ActiveStorage::VariantRecord.where(id: variant_ids).delete_all
      ActiveStorage::Blob.where(id: all_blob_ids).delete_all

      orders = Order.where(id: OrderItem.select(:order_id))
      puts "Borrando #{orders.count} pedidos de prueba que referencian productos"
      OrderItem.where(order_id: orders.select(:id)).delete_all
      orders.delete_all

      ProductImage.unscoped.delete_all
      ProductVariant.delete_all
      Product.delete_all
      Category.unscoped.delete_all
    end
    puts "Catálogo anterior borrado"
  end

  def create_categories
    CATEGORIES.keys.each_with_index.map do |name, i|
      category = Category.create!(name: name, position: i + 1)
      hex = COLORS.values[i % COLORS.size]
      category.image.attach(io: StringIO.new(photo(name, hex, 1200, 1200)),
                            filename: "#{category.slug}.jpg", content_type: "image/jpeg")
      category
    end
  end

  def create_products(categories)
    used_names = Set.new
    positions  = Hash.new(0)

    STATUSES.each_with_index do |status, i|
      category = categories[i % categories.size]
      name     = unique_name(category.name, used_names)
      price    = @rng.rand(15..75)
      flag     = pick_flag(i, status)

      product = Product.create!(
        category: category, name: name, status: status, flag: flag,
        price: price, compare_at_price: (flag == :oferta ? (price * 1.25).round : nil),
        position: positions[category.id] += 1,
        description: "#{name}: pieza de la colección naar, confeccionada con telas de calidad y buena caída. " \
                     "Combínala con tus básicos favoritos para un look casual o de noche."
      )

      colors = COLORS.to_a.sample([ 1, 1, 2, 2, 2, 3 ].sample(random: @rng), random: @rng)
      create_variants(product, colors, sold_out: status == :active && @rng.rand < 0.06)
      create_images(product, colors, status)
      print "."
    end
    puts
  end

  def unique_name(category_name, used_names)
    loop do
      name = "#{CATEGORIES[category_name].sample(random: @rng)} #{NAMES.sample(random: @rng)}"
      return name if used_names.add?(name)
    end
  end

  def pick_flag(index, status)
    return :sin_flag unless status == :active
    return :nuevo if index < 10

    roll = @rng.rand
    if roll < 0.12 then :oferta
    elsif roll < 0.17 then :bestseller
    else :sin_flag
    end
  end

  def sizes_for(product)
    case product.category.name
    when "Pantalones" then Product::NUMERIC_SIZES.each_cons(4).to_a.sample(random: @rng)
    when "Accesorios" then [ "Único" ]
    else [ %w[S M L], %w[XS S M L], %w[S M L XL] ].sample(random: @rng)
    end
  end

  def create_variants(product, colors, sold_out:)
    sizes = sizes_for(product)
    colors.each do |color_name, color_hex|
      sizes.each do |size|
        product.variants.create!(size: size, color_name: color_name, color_hex: color_hex,
                                 sku: "DEMO-#{product.id}-#{color_name.parameterize}-#{size}".upcase,
                                 stock: sold_out ? 0 : @rng.rand(0..8))
      end
    end
  end

  # Activos: una foto por color + 30% con una foto general (sin color).
  # Borradores/eliminados: la mitad con una foto general.
  def create_images(product, colors, status)
    shots = if status == :active
      colors.map { |color_name, hex| [ color_name, hex ] } + (@rng.rand < 0.3 ? [ [ nil, colors.first[1] ] ] : [])
    else
      @rng.rand < 0.5 ? [ [ nil, colors.first[1] ] ] : []
    end

    shots.each_with_index do |(color_name, hex), i|
      label = "#{product.name}\n#{color_name || 'Foto general'} · #{i + 1}/#{shots.size}"
      image = product.images.create!(color_name: color_name, position: i + 1,
                                     alt: [ product.name, color_name ].compact.join(" — "))
      image.image.attach(io: StringIO.new(photo(label, hex, *PHOTO_SIZE)),
                         filename: "#{product.name.parameterize}-#{i + 1}.jpg", content_type: "image/jpeg")
    end
  end

  # Fondo del color con ruido (para que el JPEG pese como una foto real) y el
  # texto centrado en un tono que contraste.
  def photo(label, hex, width, height)
    rgb   = hex.delete("#").scan(/../).map { |c| c.to_i(16) }
    noise = Vips::Image.gaussnoise(width, height, sigma: 8, mean: 0)
    bg    = (Vips::Image.black(width, height) + rgb + noise).cast(:uchar).copy(interpretation: :srgb)
    ink   = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) > 140 ? [ 33, 18, 24 ] : [ 251, 246, 233 ]
    text  = Vips::Image.text(label, font: "sans bold #{width / 75}", width: (width * 0.8).to_i, dpi: 300, align: :centre)
    mask  = text.embed((width - text.width) / 2, (height - text.height) / 2, width, height)
    mask.ifthenelse(ink, bg, blend: true).jpegsave_buffer(Q: 85)
  end
end
