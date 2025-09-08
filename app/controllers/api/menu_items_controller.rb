class Api::MenuItemsController < ApplicationController
  def index
    @menu_items = MenuItem.includes(:menu)
    render json: @menu_items.as_json(include: :menu)
  end
end
