require 'rails_helper'

RSpec.describe Api::MenuItemsController, type: :request do
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
    it 'returns all menu items' do
      get api_menu_items_path

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to be >= 1

      item_data = json_response.find { |i| i["name"] == menu_item.name }
      expect(item_data).not_to be_nil
      expect(item_data["name"]).to eq(menu_item.name)
      expect(item_data["price"]).to eq(menu_item.price.to_s)
      expect(item_data["menus"]).to be_an(Array)
      expect(item_data["restaurant"]).to be_a(Hash)
    end
  end
end
