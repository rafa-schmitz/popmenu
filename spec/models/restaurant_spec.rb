require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'associations' do
    it { should have_many(:menus).dependent(:destroy) }
    it { should have_many(:menu_items).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
