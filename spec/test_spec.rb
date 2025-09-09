require 'rails_helper'

RSpec.describe "Basic RSpec test" do
  it "should work" do
    expect(1 + 1).to eq(2)
  end

  it "should be able to create a restaurant" do
    restaurant = create(:restaurant)
    expect(restaurant).to be_persisted
    expect(restaurant.name).to eq("Test Restaurant")
  end
end
