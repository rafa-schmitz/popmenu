class Menu < ApplicationRecord
  belongs_to :restaurant, optional: true
  has_many :menu_menu_items, dependent: :destroy
  has_many :menu_items, through: :menu_menu_items

  validates :name, presence: true
end
