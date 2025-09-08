class Api::MenusController < ApplicationController
  def index
    @menus = Menu.includes(:restaurant, :menu_items)
    render json: @menus.as_json(include: [:restaurant, :menu_items])
  end

  def show
    @menu = Menu.includes(:restaurant, :menu_items).find(params[:id])
    render json: @menu.as_json(include: [:restaurant, :menu_items])
  end
end
