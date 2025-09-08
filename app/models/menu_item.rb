class MenuItem < ApplicationRecord
  has_many :menu_menu_items, dependent: :destroy
  has_many :menus, through: :menu_menu_items
  has_many :restaurants, through: :menus

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  validate :name_unique_per_restaurant

  private

  def name_unique_per_restaurant
    return unless name.present?
    
    restaurants.each do |restaurant|
      existing_items = restaurant.menu_items.where(name: name).where.not(id: id)
      if existing_items.exists?
        errors.add(:name, "must be unique per restaurant")
        break
      end
    end
  end
end
