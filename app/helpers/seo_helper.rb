module SeoHelper
  INSTAGRAM_URL = "https://instagram.com/naarbymanar".freeze
  TIKTOK_URL    = "https://tiktok.com/@naarbymanar".freeze

  # Base pública del sitio: en producción el dominio canónico (sin www);
  # en dev/test, el host del request.
  def site_url
    Rails.configuration.x.site_url.presence || request.base_url
  end

  # Canonical sin query string: /?utm_source=ig o /?page=2 no son páginas
  # distintas para Google.
  def canonical_url(path = request.path)
    "#{site_url}#{path}"
  end

  def json_ld_tag(data)
    # to_json escapa <, > y & (escape_html_entities_in_json), así que un
    # nombre con "</script>" no puede cerrar el tag.
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def organization_json_ld
    {
      "@context": "https://schema.org",
      "@type": "OnlineStore",
      name: "naar",
      url: "#{site_url}/",
      logo: "#{site_url}#{image_path('logo-naar.png')}",
      sameAs: [ INSTAGRAM_URL, TIKTOK_URL ],
      contactPoint: {
        "@type": "ContactPoint",
        telephone: "+58-412-051-1634",
        contactType: "customer service",
        availableLanguage: "es"
      }
    }
  end

  def website_json_ld
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      name: "naar",
      url: "#{site_url}/",
      inLanguage: "es-VE"
    }
  end
end
