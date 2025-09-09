require 'rails_helper'

RSpec.describe Api::MenusController, type: :request do
  let(:restaurant) { create(:restaurant, name: "Poppo's Cafe") }
  let(:menu) { create(:menu, name: "lunch", restaurant: restaurant) }
  let(:menu_item) { create(:menu_item, name: "Poppo's Burger", price: 9.99, restaurant: restaurant) }

  before do
    restaurant # Create the restaurant
    menu # Create the menu
    menu_item # Create the menu item
    menu.menu_items << menu_item
  end

  describe 'GET #index' do
    it 'returns all menus' do
      get api_menus_path

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to be >= 1
      
      menu_data = json_response.find { |m| m["name"] == menu.name }
      expect(menu_data).not_to be_nil
      expect(menu_data["name"]).to eq(menu.name)
      expect(menu_data["menu_items"]).to be_an(Array)
      expect(menu_data["restaurant"]).to be_present
    end
  end

  describe 'GET #show' do
    it 'returns a specific menu' do
      get api_menu_path(menu)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq(menu.name)
      expect(json_response["menu_items"]).to be_an(Array)
      expect(json_response["restaurant"]).to be_present
    end

    it 'returns 404 for non-existent menu' do
      get api_menu_path(999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
