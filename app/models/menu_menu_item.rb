class MenuMenuItem < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_id, uniqueness: { scope: :menu_item_id }
  validate :menu_and_menu_item_belong_to_same_restaurant

  private

  def menu_and_menu_item_belong_to_same_restaurant
    return unless menu && menu_item

    unless menu.restaurant_id == menu_item.restaurant_id
      errors.add(:base, "Menu and menu item must belong to the same restaurant")
    end
  end
end
