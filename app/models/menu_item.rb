class MenuItem < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_menu_items, dependent: :destroy
  has_many :menus, through: :menu_menu_items

  validates :name, presence: true, uniqueness: { scope: :restaurant_id, case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
