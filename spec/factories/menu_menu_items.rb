FactoryBot.define do
  factory :menu_menu_item do
    association :menu
    association :menu_item
  end
end
