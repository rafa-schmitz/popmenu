FactoryBot.define do
  factory :menu_item do
    name { "Test Item" }
    price { 9.99 }
    association :restaurant
  end
end
