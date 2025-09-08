class Api::MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.includes(:menus, :restaurants)
    render json: @menu_items.as_json(include: [:menus, :restaurants])
  end
end
