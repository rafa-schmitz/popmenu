class AddRestaurantToMenuItems < ActiveRecord::Migration[7.2]
  def up
    # First add the column as nullable
    add_reference :menu_items, :restaurant, null: true, foreign_key: true
    
    # Populate existing menu_items with restaurant_id from their associated menus
    execute <<-SQL
      UPDATE menu_items 
      SET restaurant_id = (
        SELECT m.restaurant_id 
        FROM menu_menu_items mmi 
        JOIN menus m ON mmi.menu_id = m.id 
        WHERE mmi.menu_item_id = menu_items.id 
        LIMIT 1
      )
    SQL
    
    # Now make it not null
    change_column_null :menu_items, :restaurant_id, false
  end
  
  def down
    remove_reference :menu_items, :restaurant, foreign_key: true
  end
end
