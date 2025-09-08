require "test_helper"

class Api::MenusControllerTest < ActionDispatch::IntegrationTest
  def setup
    @menu = Menu.create!(name: "Lunch Menu")
    @menu_item = @menu.menu_items.create!(name: "Burger", price: 9.00)
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
    assert_equal 1, menu_data["menu_items"].length
    assert_equal @menu_item.name, menu_data["menu_items"].first["name"]
  end

  test "should get show" do
    get api_menu_url(@menu)
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert_equal @menu.name, json_response["name"]
    assert_equal 1, json_response["menu_items"].length
    assert_equal @menu_item.name, json_response["menu_items"].first["name"]
  end

  test "should return 404 for non-existent menu" do
    get api_menu_url(999)
    assert_response :not_found
  end
end
