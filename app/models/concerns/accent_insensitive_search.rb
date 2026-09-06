# Búsqueda de texto sin importar acentos/mayúsculas (ej. buscar "pantalon"
# encuentra "Pantalón"), portable entre SQLite (dev/test) y Postgres (prod)
# sin depender de extensiones como `unaccent` — solo REPLACE()/LOWER(),
# soportado igual en ambos adapters.
module AccentInsensitiveSearch
  extend ActiveSupport::Concern

  ACCENTS = {
    "á" => "a", "à" => "a", "ä" => "a", "â" => "a",
    "é" => "e", "è" => "e", "ë" => "e", "ê" => "e",
    "í" => "i", "ì" => "i", "ï" => "i", "î" => "i",
    "ó" => "o", "ò" => "o", "ö" => "o", "ô" => "o",
    "ú" => "u", "ù" => "u", "ü" => "u", "û" => "u",
    "ñ" => "n"
  }.freeze

  class_methods do
    # Lado Ruby de la normalización (para el término buscado) — tiene que
    # producir el mismo resultado que unaccent_sql para el mismo string.
    def strip_accents(str)
      s = str.to_s.downcase
      ACCENTS.each { |accented, plain| s = s.gsub(accented, plain) }
      s
    end

    # Lado SQL (para la columna) — cadena de REPLACE() anidados.
    def unaccent_sql(column_sql)
      sql = "LOWER(#{column_sql})"
      ACCENTS.each { |accented, plain| sql = "REPLACE(#{sql}, '#{accented}', '#{plain}')" }
      sql
    end

    # Define un ransacker "<attr>_unaccent" para usar en filtros de admin,
    # ej: `q: { name_unaccent_cont: "pantalon" }`.
    def accent_insensitive_ransacker(attr)
      ransacker :"#{attr}_unaccent", formatter: ->(v) { strip_accents(v) } do |parent|
        Arel.sql(unaccent_sql("#{parent.table_name}.#{attr}"))
      end
    end
  end
end
