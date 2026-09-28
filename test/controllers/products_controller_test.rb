require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "gallery devuelve las fotos del producto como JSON" do
    get product_gallery_path(products(:remera))

    assert_response :success
    json = @response.parsed_body
    assert_equal %w[image images imagesByColor], json.keys.sort
  end

  test "gallery no expone productos en borrador" do
    get product_gallery_path(products(:body_borrador))

    assert_response :not_found
  end

  test "la card no embebe URLs de imágenes, solo el galleryUrl" do
    get search_path(q: "remera")

    card_data = JSON.parse(Nokogiri::HTML(@response.body).at_css(".product-card")["data-product"])
    assert_equal product_gallery_path(products(:remera)), card_data["galleryUrl"]
    assert_not card_data.key?("images")
  end
end
