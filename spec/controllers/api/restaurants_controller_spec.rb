require 'rails_helper'

RSpec.describe Api::RestaurantsController, type: :request do
  let(:restaurant) { create(:restaurant, name: "Poppo's Cafe") }

  before do
    restaurant # Create the restaurant
  end

  describe 'GET #index' do
    it 'returns all restaurants' do
      get api_restaurants_path

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response.length).to be >= 1

      restaurant_data = json_response.find { |r| r["name"] == restaurant.name }
      expect(restaurant_data).not_to be_nil
      expect(restaurant_data["name"]).to eq(restaurant.name)
      expect(restaurant_data["menus"]).to be_an(Array)
    end
  end

  describe 'GET #show' do
    it 'returns a specific restaurant' do
      get api_restaurant_path(restaurant)

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response["name"]).to eq(restaurant.name)
      expect(json_response["menus"]).to be_an(Array)
    end

    it 'returns 404 for non-existent restaurant' do
      get api_restaurant_path(99999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
