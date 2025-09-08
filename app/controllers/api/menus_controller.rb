class Api::MenusController < ApplicationController
  def index
    @menus = Menu.includes(:menu_items)
    render json: @menus.as_json(include: :menu_items)
  end

  def show
    @menu = Menu.includes(:menu_items).find(params[:id])
    render json: @menu.as_json(include: :menu_items)
  end
end
