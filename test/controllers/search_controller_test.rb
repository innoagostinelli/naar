require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "encuentra productos activos por nombre" do
    get search_path(q: "remera")

    assert_response :success
    assert_includes @response.body, products(:remera).name
    assert_not_includes @response.body, products(:vestido).name
  end

  test "encuentra productos activos por descripcion" do
    get search_path(q: "sandalias")

    assert_response :success
    assert_includes @response.body, products(:vestido).name
  end

  test "no incluye productos en borrador" do
    get search_path(q: "encaje")

    assert_response :success
    assert_not_includes @response.body, products(:body_borrador).name
  end

  test "sin coincidencias muestra mensaje de sin resultados" do
    get search_path(q: "zzzxyz")

    assert_response :success
    assert_includes @response.body, "No encontramos resultados"
  end

  test "query en blanco no ejecuta busqueda ni rompe" do
    get search_path

    assert_response :success
    assert_includes @response.body, "Busca tu próxima prenda favorita"
  end

  test "peticion de turbo frame limita resultados y usa layout minimo" do
    get search_path(q: "e"), headers: { "Turbo-Frame" => "search_preview_frame" }

    assert_response :success
    assert_select "turbo-frame#search_preview_frame"
    assert_select "header.site-header", 0
  end

  test "peticion normal devuelve pagina completa con resultados fuera del frame de preview" do
    get search_path(q: "remera")

    assert_response :success
    assert_select "header.site-header"
    # El único turbo-frame#search_preview_frame de la página es el del overlay del
    # header (siempre presente en el layout, vacío); los resultados completos van aparte.
    assert_select "turbo-frame#search_preview_frame", 1
    assert_select ".search-results-page .products .product-card", count: 1
  end
end
