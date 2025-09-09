require 'rails_helper'

RSpec.describe Api::ImportsController, type: :request do
  let(:valid_json) do
    {
      "restaurants" => [
        {
          "name" => "Test Restaurant",
          "menus" => [
            {
              "name" => "lunch",
              "menu_items" => [
                {
                  "name" => "Test Burger",
                  "price" => 9.99
                }
              ]
            }
          ]
        }
      ]
    }.to_json
  end

  let(:invalid_json) { '{"invalid": "structure"}' }

  describe 'POST #create' do
    context 'with valid JSON data' do
      it 'imports the data successfully' do
        post api_imports_path,
             params: valid_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
        expect(json_response["logs"]).to be_an(Array)
        expect(json_response["success_count"]).to be > 0
      end
    end

    context 'with invalid JSON structure' do
      it 'returns unprocessable entity' do
        post api_imports_path,
             params: invalid_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be false
        expect(json_response["logs"]).to be_an(Array)
      end
    end

    context 'with raw JSON in request body' do
      it 'processes the JSON successfully' do
        post api_imports_path,
             params: valid_json,
             headers: { "Content-Type" => "application/json" }

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response["success"]).to be true
      end
    end
  end
end
