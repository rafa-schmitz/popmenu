FactoryBot.define do
  factory :menu do
    name { "Test Menu" }
    association :restaurant
  end
end
