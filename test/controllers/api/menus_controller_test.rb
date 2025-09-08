require "test_helper"

class Api::MenusControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = restaurants(:poppos_cafe)
    @menu = menus(:poppos_lunch)
    @menu_item = menu_items(:poppos_burger)
  end

  test "should get index" do
    get api_menus_url
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert json_response.length >= 1
    menu_data = json_response.find { |m| m["name"] == @menu.name }
    assert_not_nil menu_data
    assert_equal @menu.name, menu_data["name"]
    assert menu_data["menu_items"].is_a?(Array)
    assert menu_data["restaurant"].present?
  end

  test "should get show" do
    get api_menu_url(@menu)
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert_equal @menu.name, json_response["name"]
    assert json_response["menu_items"].is_a?(Array)
    assert json_response["restaurant"].present?
  end

  test "should return 404 for non-existent menu" do
    get api_menu_url(999)
    assert_response :not_found
  end
end
