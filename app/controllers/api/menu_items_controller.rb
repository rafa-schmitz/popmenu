class Api::MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.includes(:menus, :restaurant)
    render json: @menu_items.as_json(include: [ :menus, :restaurant ])
  end
end
