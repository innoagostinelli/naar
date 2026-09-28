require "test_helper"

class SeoTest < ActionDispatch::IntegrationTest
  test "el canonical y og:url ignoran el query string" do
    get root_path(utm_source: "ig", page: 2)

    doc = Nokogiri::HTML(@response.body)
    assert_equal "http://www.example.com/", doc.at_css('link[rel="canonical"]')["href"]
    assert_equal "http://www.example.com/", doc.at_css('meta[property="og:url"]')["content"]
  end

  test "el canonical usa el dominio configurado aunque el request venga por otro host" do
    with_site_url("https://naarbymanar.com") do
      host! "www.naarbymanar.com"
      get root_path

      assert_equal "https://naarbymanar.com/", Nokogiri::HTML(@response.body).at_css('link[rel="canonical"]')["href"]
    end
  end

  test "la home incluye JSON-LD de la tienda y del sitio" do
    get root_path

    types = Nokogiri::HTML(@response.body).css('script[type="application/ld+json"]').map { |s| JSON.parse(s.text)["@type"] }
    assert_equal %w[OnlineStore WebSite], types.sort
  end

  test "la búsqueda no es indexable" do
    get search_path(q: "remera")

    assert_equal "noindex, follow", Nokogiri::HTML(@response.body).at_css('meta[name="robots"]')["content"]
  end

  test "la home sí es indexable" do
    get root_path

    assert_equal "index, follow", Nokogiri::HTML(@response.body).at_css('meta[name="robots"]')["content"]
  end

  test "sitemap.xml lista la home" do
    get sitemap_path

    assert_response :success
    assert_equal "application/xml", @response.media_type
    locs = Nokogiri::XML(@response.body).remove_namespaces!.css("url loc").map(&:text)
    assert_equal [ "http://www.example.com/" ], locs
  end

  private

  def with_site_url(url)
    previous = Rails.configuration.x.site_url
    Rails.configuration.x.site_url = url
    yield
  ensure
    Rails.configuration.x.site_url = previous
  end
end
