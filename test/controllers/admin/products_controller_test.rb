require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post admin_login_path, params: {
      username: admin_users(:naar_admin).username,
      password: "clave-de-test-123"
    }
  end

  def sql_count(&block)
    # El query cache sobrevive entre requests del test si no hubo escrituras.
    ActiveRecord::Base.connection.clear_query_cache
    counter = ActiveRecord::Assertions::QueryAssertions::SQLCounter.new
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    counter.log.size
  end

  def attach_photo(product, position: 0)
    product.images.create!(position: position).tap do |img|
      img.image.attach(io: file_fixture("sample.jpg").open, filename: "sample.jpg", content_type: "image/jpeg")
    end
  end

  test "el listado muestra la miniatura de la primera foto" do
    product = Product.not_deleted.first
    attach_photo(product, position: 1)
    first = attach_photo(product, position: 0)

    get admin_products_path

    assert_response :success
    assert_select "img.admin-thumb[loading=lazy][width='40']", minimum: 1
    assert_includes response.body, first.image.blob.signed_id
  end

  test "la miniatura lleva la URL de la vista previa grande pero no la descarga" do
    attach_photo(Product.not_deleted.first)

    get admin_products_path

    assert_select "[data-controller=thumb-preview] img.admin-thumb[data-preview-url]", minimum: 1
    assert_select "img[src*='600x800'], img.thumb-preview", 0
  end

  test "producto sin fotos muestra el placeholder" do
    get admin_products_path

    assert_response :success
    assert_select ".admin-thumb-empty", minimum: 1
  end

  test "usa la URL directa si la miniatura ya fue generada" do
    img = attach_photo(Product.not_deleted.first)
    img.image.variant(:thumb).processed

    get admin_products_path

    assert_select "img.admin-thumb[src*='/rails/active_storage/disk/']"
  end

  test "la cantidad de consultas no crece con los productos con foto" do
    products = Product.not_deleted.limit(3).to_a
    attach_photo(products.first)
    get admin_products_path
    with_one = sql_count { get admin_products_path }

    products.drop(1).each { |p| attach_photo(p) }
    get admin_products_path
    with_three = sql_count { get admin_products_path }

    assert_operator with_one, :>, 0
    assert_equal with_one, with_three
  end

  test "productos eliminados tambien muestra miniatura" do
    product = Product.not_deleted.first
    attach_photo(product)
    product.update_column(:status, Product.statuses[:deleted])

    get deleted_admin_products_path

    assert_select "img.admin-thumb", 1
  end
end
