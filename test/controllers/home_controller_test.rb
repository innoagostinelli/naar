require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "la home lista los productos activos por categoría" do
    get root_path

    assert_response :success
    assert_includes @response.body, products(:remera).name
    assert_includes @response.body, products(:vestido).name
    assert_not_includes @response.body, products(:body_borrador).name
  end
end
