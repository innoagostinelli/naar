namespace :catalog do
  desc "Genera la miniatura :thumb de las fotos de producto que todavía no la tienen (de a una, para no saturar el server)"
  task generate_thumbnails: :environment do
    images = ProductImage.unscoped.joins(:image_attachment).includes(image_attachment: { blob: :variant_records })
    total = images.count
    generated = skipped = failed = 0

    images.find_each.with_index(1) do |img, i|
      variant = img.image.variant(:thumb)
      if variant.image # ya hay variant record (sin pedir URL: no hace falta url_options)
        skipped += 1
      else
        variant.processed
        generated += 1
      end
    rescue StandardError => e
      failed += 1
      puts "  [#{i}/#{total}] ProductImage ##{img.id}: #{e.class} — #{e.message}"
    ensure
      puts "  #{i}/#{total}..." if (i % 25).zero?
    end

    puts "Miniaturas: #{generated} generadas, #{skipped} ya existían, #{failed} con error (de #{total} fotos)."
  end
end
