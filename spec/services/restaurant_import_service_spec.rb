require 'rails_helper'

RSpec.describe RestaurantImportService do
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
                },
                {
                  "name" => "Test Salad",
                  "price" => 5.50
                }
              ]
            },
            {
              "name" => "dinner",
              "dishes" => [
                {
                  "name" => "Test Burger",
                  "price" => 15.99
                }
              ]
            }
          ]
        }
      ]
    }
  end

  describe '#import' do
    context 'with valid restaurant data' do
      it 'imports data successfully' do
        service = described_class.new(valid_json)
        result = service.import

        expect(result[:success]).to be true
        expect(result[:success_count]).to eq(3) # 3 menu items processed (2 unique per restaurant, 1 duplicate name)
        expect(result[:error_count]).to eq(0)
        expect(result[:logs]).to include(hash_including(message: match(/Created new restaurant/)))
        expect(result[:logs]).to include(hash_including(message: match(/Created new menu/)))
        expect(result[:logs]).to include(hash_including(message: match(/Created new menu item/)))

        # Verify data was created
        restaurant = Restaurant.find_by(name: "Test Restaurant")
        expect(restaurant).not_to be_nil
        expect(restaurant.menus.count).to eq(2)
        expect(restaurant.menu_items.count).to eq(2) # 2 unique menu items per restaurant (Test Burger, Test Salad)

        # Verify restaurant-scoped uniqueness - 2 unique menu items exist for this restaurant
        expect(MenuItem.count).to eq(2)
        expect(restaurant.menu_items.count).to eq(2)
      end
    end

    context 'with dishes vs menu_items key variants' do
      let(:json_with_dishes) do
        {
          "restaurants" => [
            {
              "name" => "Dish Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "dishes" => [
                    {
                      "name" => "Dish Item",
                      "price" => 10.00
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'handles dishes key correctly' do
        service = described_class.new(json_with_dishes)
        result = service.import

        expect(result[:success]).to be true
        expect(result[:success_count]).to eq(1)

        restaurant = Restaurant.find_by(name: "Dish Restaurant")
        expect(restaurant).not_to be_nil
        expect(restaurant.menu_items.count).to eq(1)
        expect(restaurant.menu_items.first.name).to eq("Dish Item")
      end
    end

    context 'with duplicate menu items across menus' do
      let(:json_with_duplicates) do
        {
          "restaurants" => [
            {
              "name" => "Duplicate Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "Same Burger",
                      "price" => 9.99
                    }
                  ]
                },
                {
                  "name" => "dinner",
                  "menu_items" => [
                    {
                      "name" => "Same Burger",
                      "price" => 15.99
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'handles duplicate menu items correctly' do
        service = described_class.new(json_with_duplicates)
        result = service.import

        expect(result[:success]).to be true
        expect(result[:success_count]).to eq(2) # 2 menu items processed (same name, different prices)

        restaurant = Restaurant.find_by(name: "Duplicate Restaurant")
        expect(restaurant.menu_items.count).to eq(1) # Only one unique menu item (same name)
        expect(restaurant.menus.count).to eq(2) # But two menus
        expect(restaurant.menus.all? { |menu| menu.menu_items.include?(restaurant.menu_items.first) }).to be true

        # Verify only one menu item exists for this restaurant
        expect(MenuItem.count).to eq(1)
        expect(MenuItem.first.price).to eq(15.99) # Price should be updated to the last processed price
      end
    end

    context 'with price normalization' do
      let(:json_with_various_prices) do
        {
          "restaurants" => [
            {
              "name" => "Price Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "Numeric Price",
                      "price" => 9.99
                    },
                    {
                      "name" => "String Price",
                      "price" => "12.50"
                    },
                    {
                      "name" => "Dollar Price",
                      "price" => "$15.00"
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'normalizes various price formats' do
        service = described_class.new(json_with_various_prices)
        result = service.import

        expect(result[:success]).to be true
        expect(result[:success_count]).to eq(3)

        restaurant = Restaurant.find_by(name: "Price Restaurant")
        menu_items = restaurant.menu_items.order(:name)

        expect(menu_items.find_by(name: "Numeric Price").price).to eq(9.99)
        expect(menu_items.find_by(name: "String Price").price).to eq(12.50)
        expect(menu_items.find_by(name: "Dollar Price").price).to eq(15.00)
      end
    end

    context 'with validation errors' do
      let(:invalid_json) do
        {
          "restaurants" => [
            {
              "name" => "", # Invalid: empty name
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "Test Item",
                      "price" => "invalid_price" # Invalid price
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'handles validation errors gracefully' do
        service = described_class.new(invalid_json)
        result = service.import

        expect(result[:success]).to be false
        expect(result[:success_count]).to eq(0)
        expect(result[:error_count]).to be > 0
        expect(result[:logs]).to include(hash_including(level: "error"))
      end
    end

    context 'with missing required fields' do
      let(:incomplete_json) do
        {
          "restaurants" => [
            {
              "name" => "Incomplete Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "", # Missing name
                      "price" => 9.99
                    },
                    {
                      "name" => "No Price Item"
                      # Missing price
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'handles missing required fields' do
        service = described_class.new(incomplete_json)
        result = service.import

        expect(result[:success]).to be false
        expect(result[:error_count]).to be > 0
        expect(result[:logs]).to include(hash_including(message: match(/name is required/)))
        expect(result[:logs]).to include(hash_including(message: match(/price is required/)))
      end
    end

    context 'with invalid JSON structure' do
      let(:invalid_structure) { { "invalid" => "structure" } }

      it 'handles invalid JSON structure' do
        service = described_class.new(invalid_structure)
        result = service.import

        expect(result[:success]).to be false
        expect(result[:logs]).to include(hash_including(message: match(/Invalid JSON structure/)))
      end
    end

    context 'with empty restaurants array' do
      let(:empty_json) { { "restaurants" => [] } }

      it 'handles empty restaurants array' do
        service = described_class.new(empty_json)
        result = service.import

        expect(result[:success]).to be false
        expect(result[:logs]).to include(hash_including(message: match(/No restaurants found/)))
      end
    end

    context 'with existing data' do
      it 'updates existing restaurant and menu items' do
        # Create existing data
        restaurant = Restaurant.create!(name: "Test Restaurant")
        menu = restaurant.menus.create!(name: "lunch")
        menu_item = MenuItem.create!(name: "Test Burger", price: 5.00, restaurant: restaurant)
        menu.menu_items << menu_item

        # Import with updated data
        service = described_class.new(valid_json)
        result = service.import

        expect(result[:success]).to be true

        # Verify existing restaurant was used
        expect(Restaurant.where(name: "Test Restaurant").count).to eq(1)
        expect(restaurant.menus.where(name: "lunch").count).to eq(1)

        # Verify price was updated (to the last processed price)
        updated_item = restaurant.menu_items.find_by(name: "Test Burger")
        expect(updated_item.price).to be_within(0.01).of(15.99)
      end
    end

    context 'with same menu item names across different restaurants' do
      it 'allows same menu item names across different restaurants' do
        # First, import data for one restaurant
        first_restaurant_json = {
          "restaurants" => [
            {
              "name" => "First Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "Shared Burger",
                      "price" => 9.99
                    }
                  ]
                }
              ]
            }
          ]
        }

        service1 = described_class.new(first_restaurant_json)
        result1 = service1.import

        expect(result1[:success]).to be true
        expect(MenuItem.count).to eq(1)
        expect(MenuItem.first.name).to eq("Shared Burger")

        # Now import data for a second restaurant with the same menu item name
        second_restaurant_json = {
          "restaurants" => [
            {
              "name" => "Second Restaurant",
              "menus" => [
                {
                  "name" => "dinner",
                  "menu_items" => [
                    {
                      "name" => "Shared Burger",
                      "price" => 15.99
                    }
                  ]
                }
              ]
            }
          ]
        }

        service2 = described_class.new(second_restaurant_json)
        result2 = service2.import

        expect(result2[:success]).to be true

        # Should have 2 menu items (one for each restaurant)
        expect(MenuItem.count).to eq(2)

        # Each restaurant should have its own menu item
        first_restaurant = Restaurant.find_by(name: "First Restaurant")
        second_restaurant = Restaurant.find_by(name: "Second Restaurant")

        expect(first_restaurant.menu_items.count).to eq(1)
        expect(second_restaurant.menu_items.count).to eq(1)
        expect(first_restaurant.menu_items.first).not_to eq(second_restaurant.menu_items.first)

        # Each should have the correct price
        expect(first_restaurant.menu_items.first.price).to eq(9.99)
        expect(second_restaurant.menu_items.first.price).to eq(15.99)
      end
    end

    context 'with case insensitive uniqueness within restaurant' do
      let(:json_with_mixed_case) do
        {
          "restaurants" => [
            {
              "name" => "Case Restaurant",
              "menus" => [
                {
                  "name" => "lunch",
                  "menu_items" => [
                    {
                      "name" => "Mixed Case Burger",
                      "price" => 9.99
                    },
                    {
                      "name" => "MIXED CASE BURGER",
                      "price" => 12.99
                    }
                  ]
                }
              ]
            }
          ]
        }
      end

      it 'handles case insensitive uniqueness within restaurant' do
        service = described_class.new(json_with_mixed_case)
        result = service.import

        expect(result[:success]).to be true
        expect(result[:success_count]).to eq(2) # Both items processed

        # Should only have 1 menu item due to case-insensitive uniqueness within restaurant
        expect(MenuItem.count).to eq(1)
        expect(MenuItem.first.name).to eq("Mixed Case Burger")
        expect(MenuItem.first.price).to eq(12.99) # Price should be updated to the last processed
      end
    end
  end
end
