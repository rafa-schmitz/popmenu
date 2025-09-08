require "test_helper"

class Api::RestaurantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = restaurants(:poppos_cafe)
  end

  test "should get index" do
    get api_restaurants_url
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert json_response.length >= 1
    restaurant_data = json_response.find { |r| r["name"] == @restaurant.name }
    assert_not_nil restaurant_data
    assert_equal @restaurant.name, restaurant_data["name"]
    assert restaurant_data["menus"].is_a?(Array)
  end

  test "should get show" do
    get api_restaurant_url(@restaurant)
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    json_response = JSON.parse(response.body)
    assert_equal @restaurant.name, json_response["name"]
    assert json_response["menus"].is_a?(Array)
  end

  test "should return 404 for non-existent restaurant" do
    get api_restaurant_url(99999)
    assert_response :not_found
  end
end
