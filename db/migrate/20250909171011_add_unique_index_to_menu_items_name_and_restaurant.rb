class AddUniqueIndexToMenuItemsNameAndRestaurant < ActiveRecord::Migration[7.2]
  def change
    add_index :menu_items, [:name, :restaurant_id], unique: true
  end
end
