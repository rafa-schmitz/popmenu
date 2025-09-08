require "test_helper"

class Api::MenuItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = restaurants(:poppos_cafe)
    @menu = menus(:poppos_lunch)
    @menu_item = menu_items(:poppos_burger)
  end

  test "should get index" do
    get api_menu_items_url
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert json_response.length >= 1
    item_data = json_response.find { |i| i["name"] == @menu_item.name }
    assert_not_nil item_data
    assert_equal @menu_item.name, item_data["name"]
    assert_equal @menu_item.price.to_s, item_data["price"]
    assert item_data["menus"].is_a?(Array)
    assert item_data["restaurants"].is_a?(Array)
  end
end
