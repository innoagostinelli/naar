puts "Seeding naar..."

# ── Categorías ──────────────────────────────────────────────────
categories_data = [
  { name: "Vestidos",   slug: "vestidos",   position: 1 },
  { name: "Tops",       slug: "tops",       position: 2 },
  { name: "Sets",       slug: "sets",       position: 3 },
  { name: "Faldas",     slug: "faldas",     position: 4 },
  { name: "Pantalones", slug: "pantalones", position: 5 },
  { name: "Bodys",      slug: "bodys",      position: 6 },
  { name: "Suéteres",   slug: "sueteres",   position: 7 },
  { name: "Rompers",    slug: "rompers",    position: 8 },
  { name: "Shorts",     slug: "shorts",     position: 9 },
  { name: "Chaquetas",  slug: "chaquetas",  position: 10 },
  { name: "Descuentos", slug: "descuentos", position: 11 },
]

categories_data.each do |data|
  Category.find_or_create_by!(slug: data[:slug]) { |c| c.assign_attributes(data) }
end

puts "  #{Category.count} categorías creadas"

# Helper para crear producto + variantes de color
def create_product(category_slug:, name:, price:, compare_at_price: nil, flag: :sin_flag, status: :active, position: 1, swatches: [], description: nil)
  cat = Category.find_by!(slug: category_slug)
  product = Product.find_or_create_by!(name: name, category: cat) do |p|
    p.price            = price
    p.compare_at_price = compare_at_price
    p.flag             = flag
    p.status           = status
    p.position         = position
    p.description      = description
  end

  swatches.each_with_index do |(color_hex, color_name), i|
    %w[XS S M L XL].each do |size|
      ProductVariant.find_or_create_by!(product: product, size: size, color_hex: color_hex) do |v|
        v.color_name = color_name
        v.stock      = 10
      end
    end
  end

  product
end

# ── Nuevos ingresos ─────────────────────────────────────────────
create_product(category_slug: "vestidos",   name: "Vestido midi",          price: 55, flag: :nuevo,      position: 1,  swatches: [["#211218","Negro"],["#820045","Burgundy"]])
create_product(category_slug: "vestidos",   name: "Vestido midi Sol",      price: 68, compare_at_price: 78, flag: :oferta, position: 2, swatches: [["#F2E651","Amarillo"],["#FBF6E9","Crema"]])
create_product(category_slug: "pantalones", name: "Pantalón lino Camila",  price: 55, flag: :nuevo,      position: 1,  swatches: [["#FBF6E9","Crema"],["#5a4751","Malva"]])
create_product(category_slug: "bodys",      name: "Body satinado Lucía",   price: 36, flag: :nuevo,      position: 1,  swatches: [["#820045","Burgundy"],["#211218","Negro"]])
create_product(category_slug: "faldas",     name: "Falda larga Valentina", price: 48, flag: :nuevo,      position: 1,  swatches: [["#211218","Negro"],["#FBF6E9","Crema"]])
create_product(category_slug: "sueteres",   name: "Suéter punto Andrea",   price: 62, flag: :nuevo,      position: 1,  swatches: [["#FBF6E9","Crema"],["#a52b6a","Rosa"]])
create_product(category_slug: "shorts",     name: "Short denim Antonia",   price: 38, compare_at_price: 45, flag: :oferta, position: 1, swatches: [["#5a4751","Malva"],["#211218","Negro"]])
create_product(category_slug: "tops",       name: "Crop top Renata",       price: 32, flag: :sin_flag,       position: 1,  swatches: [["#FBF6E9","Crema"],["#F2E651","Amarillo"]])

# ── Tops ────────────────────────────────────────────────────────
create_product(category_slug: "tops", name: "Top off-shoulder Aurora", price: 38, flag: :sin_flag,       position: 2, swatches: [["#FBF6E9","Crema"]])
create_product(category_slug: "tops", name: "Blusa cuello v Daniela",  price: 42, flag: :sin_flag,       position: 3, swatches: [["#211218","Negro"],["#820045","Burgundy"]])
create_product(category_slug: "tops", name: "Top encaje Inés",         price: 45, flag: :bestseller,  position: 4, swatches: [["#FBF6E9","Crema"]])
create_product(category_slug: "tops", name: "Camisa lino Bianca",      price: 52, flag: :sin_flag,       position: 5, swatches: [["#FBF6E9","Crema"],["#5a4751","Malva"]])

# ── Bodys ───────────────────────────────────────────────────────
create_product(category_slug: "bodys", name: "Body manga larga Olivia", price: 34, flag: :sin_flag,        position: 2, swatches: [["#211218","Negro"],["#820045","Burgundy"]])
create_product(category_slug: "bodys", name: "Body strapless Camila",   price: 36, compare_at_price: 42, flag: :oferta, position: 3, swatches: [["#FBF6E9","Crema"]])
create_product(category_slug: "bodys", name: "Body encaje Isadora",     price: 44, flag: :bestseller,   position: 4, swatches: [["#820045","Burgundy"],["#211218","Negro"]])
create_product(category_slug: "bodys", name: "Body básico Antonella",   price: 28, flag: :sin_flag,        position: 5, swatches: [["#FBF6E9","Crema"],["#211218","Negro"],["#820045","Burgundy"]])

# ── Suéteres ────────────────────────────────────────────────────
create_product(category_slug: "sueteres", name: "Cardigan tejido Marina",  price: 58, flag: :sin_flag,        position: 2, swatches: [["#FBF6E9","Crema"]])
create_product(category_slug: "sueteres", name: "Suéter oversized Romina", price: 64, flag: :bestseller,   position: 3, swatches: [["#5a4751","Malva"]])
create_product(category_slug: "sueteres", name: "Suéter trenzado Belén",   price: 62, compare_at_price: 72, flag: :oferta, position: 4, swatches: [["#a52b6a","Rosa"]])
create_product(category_slug: "sueteres", name: "Cardigan corto Luna",     price: 54, flag: :sin_flag,        position: 5, swatches: [["#F2E651","Amarillo"],["#FBF6E9","Crema"]])

# ── Faldas ──────────────────────────────────────────────────────
create_product(category_slug: "faldas", name: "Falda plisada Emilia",  price: 46, flag: :sin_flag,        position: 2, swatches: [["#211218","Negro"],["#820045","Burgundy"]])
create_product(category_slug: "faldas", name: "Mini falda denim Sara", price: 38, flag: :sin_flag,        position: 3, swatches: [["#5a4751","Malva"]])
create_product(category_slug: "faldas", name: "Maxi falda Florencia",  price: 54, flag: :bestseller,   position: 4, swatches: [["#FBF6E9","Crema"]])
create_product(category_slug: "faldas", name: "Falda lápiz Adriana",   price: 48, compare_at_price: 56, flag: :oferta, position: 5, swatches: [["#211218","Negro"]])

# ── Shorts ──────────────────────────────────────────────────────
create_product(category_slug: "shorts", name: "Short alto Catalina",    price: 34, flag: :sin_flag,   position: 2, swatches: [["#FBF6E9","Crema"],["#211218","Negro"]])
create_product(category_slug: "shorts", name: "Short paperbag Mía",     price: 38, flag: :sin_flag,   position: 3, swatches: [["#5a4751","Malva"]])
create_product(category_slug: "shorts", name: "Short ciclista Valeria", price: 28, flag: :oferta, position: 4, swatches: [["#211218","Negro"]])
create_product(category_slug: "shorts", name: "Short lino Paloma",      price: 42, flag: :sin_flag,   position: 5, swatches: [["#FBF6E9","Crema"]])

# ── Pantalones ──────────────────────────────────────────────────
create_product(category_slug: "pantalones", name: "Pantalón wide leg Julia", price: 58, flag: :bestseller,  position: 2, swatches: [["#211218","Negro"],["#FBF6E9","Crema"]])
create_product(category_slug: "pantalones", name: "Jean recto Lola",         price: 62, flag: :sin_flag,        position: 3, swatches: [["#5a4751","Malva"]])
create_product(category_slug: "pantalones", name: "Pantalón cargo Renée",    price: 56, compare_at_price: 65, flag: :oferta, position: 4, swatches: [["#5a4751","Malva"]])
create_product(category_slug: "pantalones", name: "Jogger satinado Elena",   price: 48, flag: :sin_flag,        position: 5, swatches: [["#211218","Negro"],["#820045","Burgundy"]])

# ── Vestidos (adicionales) ───────────────────────────────────────
create_product(category_slug: "vestidos", name: "Vestido lencero Aitana",  price: 62, flag: :bestseller,   position: 3, swatches: [["#820045","Burgundy"],["#211218","Negro"]])
create_product(category_slug: "vestidos", name: "Vestido corto Salomé",    price: 54, compare_at_price: 65, flag: :oferta, position: 4, swatches: [["#211218","Negro"]])
create_product(category_slug: "vestidos", name: "Maxi vestido Constanza",  price: 78, flag: :nuevo,        position: 5, swatches: [["#F2E651","Amarillo"],["#FBF6E9","Crema"]])
create_product(category_slug: "vestidos", name: "Vestido Polka Dot",       price: 100, compare_at_price: 120, flag: :oferta, position: 6,
  description: "Tu vestido para esa noche que vas a recordar. Estampado polka dot con una silueta que define sin apretar.",
  swatches: [["#FBF6E9","Crema"]])

puts "  #{Product.count} productos creados"
puts "  #{ProductVariant.count} variantes creadas"

# ── FAQs ────────────────────────────────────────────────────────
faqs_data = [
  { question: "¿Cómo pago mi pedido?",
    answer: "Aceptamos Zelle, Pago Móvil, Binance, PayPal, transferencia bancaria y efectivo al recibir tu pedido (solo en Lechería, Puerto La Cruz y alrededores). Confirmamos todos los detalles por WhatsApp antes del envío.",
    position: 1 },
  { question: "¿A dónde envían?",
    answer: "Hacemos delivery a toda Venezuela 🇻🇪. En Lechería, Puerto La Cruz y alrededores entregamos el mismo día. Para envíos nacionales salen al siguiente día hábil.",
    position: 2 },
  { question: "¿Cuánto tiempo tarda en llegar mi pedido?",
    answer: "Los envíos nacionales dentro de Venezuela tardan entre 2 y 3 días hábiles en llegar, dependiendo de tu ciudad. Te notificamos en cuanto tu pedido sea despachado.",
    position: 3 },
  { question: "¿Puedo hacer un cambio si no me queda la talla?",
    answer: "Sí. Tienes 2 días hábiles desde que recibes tu pedido para solicitar un cambio, sujeto a disponibilidad. La prenda debe estar sin usar y en las mismas condiciones en que la recibiste. Escríbenos por Instagram o WhatsApp con tu pedido y lo gestionamos.",
    position: 4 },
  { question: "¿Cómo sé cuál es mi talla?",
    answer: "No tenemos una guía de tallas estándar porque cada prenda puede tener una horma diferente. Lo mejor es escribirnos directamente por Instagram (@naarbymanar) o WhatsApp (0412-0511634) y te asesoramos con la horma específica de cada pieza para que elijas la talla perfecta para ti.",
    position: 5 },
  { question: "¿Las piezas son ediciones limitadas?",
    answer: "Sí. Naar es un emprendimiento que trabaja con cantidades pequeñas y seleccionadas. Esto nos permite cuidar la calidad de cada pieza y que no todo el mundo tenga lo mismo. Cuando una talla se agota, puede no volver, así que si algo te gusta, no lo dejes para después.",
    position: 6 },
  { question: "¿Cómo hago para comprar?",
    answer: '1) Elige tus prendas y agrégalas al carrito. 2) Haz clic en "Finalizar por WhatsApp". 3) Confirmamos contigo el pago y la dirección de entrega. ¡Listo!',
    position: 7 },
]

faqs_data.each do |data|
  Faq.find_or_create_by!(question: data[:question]) { |f| f.assign_attributes(data) }
end

puts "  #{Faq.count} FAQs creadas"

# ── Reels ────────────────────────────────────────────────────────
reels_data = [
  { tag: "Lookbook", label: "Pijama set rayas",    position: 1 },
  { tag: "Try-on",   label: "Top encaje Inés",      position: 2 },
  { tag: "Unboxing", label: "Pedido naar #420",     position: 3 },
]

reels_data.each do |data|
  Reel.find_or_create_by!(label: data[:label]) { |r| r.assign_attributes(data) }
end

puts "  #{Reel.count} reels creados"
puts "Seed completado ✓"
