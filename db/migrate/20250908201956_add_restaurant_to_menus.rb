class AddRestaurantToMenus < ActiveRecord::Migration[7.2]
  def change
    add_reference :menus, :restaurant, null: true, foreign_key: true
    # For existing menus, we'll need to handle this in a data migration
    # For now, we'll allow null values and handle it in the application
  end
end
