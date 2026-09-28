xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc "#{site_url}/"
    xml.lastmod @home_lastmod.iso8601 if @home_lastmod
  end
end
