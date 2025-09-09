require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  let(:restaurant) { create(:restaurant) }
  let(:menu_item) { build(:menu_item, restaurant: restaurant) }

  describe 'associations' do
    it { should belong_to(:restaurant) }
    it { should have_many(:menu_menu_items).dependent(:destroy) }
    it { should have_many(:menus).through(:menu_menu_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

    context 'uniqueness validations' do
      let!(:existing_item) { create(:menu_item, name: "Test Burger", restaurant: restaurant) }

      it 'validates uniqueness of name within same restaurant (case insensitive)' do
        duplicate_item = build(:menu_item, name: "TEST BURGER", restaurant: restaurant)
        expect(duplicate_item).not_to be_valid
        expect(duplicate_item.errors[:name]).to include("has already been taken")
      end

      it 'validates uniqueness with exact case within same restaurant' do
        duplicate_item = build(:menu_item, name: "Test Burger", restaurant: restaurant)
        expect(duplicate_item).not_to be_valid
        expect(duplicate_item.errors[:name]).to include("has already been taken")
      end

      it 'validates uniqueness with different case within same restaurant' do
        duplicate_item = build(:menu_item, name: "test burger", restaurant: restaurant)
        expect(duplicate_item).not_to be_valid
        expect(duplicate_item.errors[:name]).to include("has already been taken")
      end

      it 'allows same menu item names across different restaurants' do
        other_restaurant = create(:restaurant, name: "Other Restaurant")
        duplicate_item = build(:menu_item, name: "Test Burger", restaurant: other_restaurant)
        expect(duplicate_item).to be_valid
        expect(duplicate_item.save).to be true
      end
    end

    context 'price validations' do
      it 'is valid with a positive price' do
        menu_item.price = 5.50
        expect(menu_item).to be_valid
      end

      it 'is valid with zero price' do
        menu_item.price = 0
        expect(menu_item).to be_valid
      end

      it 'is invalid with negative price' do
        menu_item.price = -1
        expect(menu_item).not_to be_valid
        expect(menu_item.errors[:price]).to include("must be greater than or equal to 0")
      end

      it 'is invalid with non-numeric price' do
        menu_item.price = "not a number"
        expect(menu_item).not_to be_valid
        expect(menu_item.errors[:price]).to include("is not a number")
      end
    end
  end

  describe 'callbacks' do
    it 'destroys associated menu_menu_items when destroyed' do
      menu_item.save!
      menu = restaurant.menus.create!(name: "Test Menu")
      menu.menu_items << menu_item
      
      expect { menu_item.destroy }.to change { MenuMenuItem.count }.by(-1)
    end
  end
end
