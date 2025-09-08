class Api::RestaurantsController < ApplicationController
  def index
    @restaurants = Restaurant.includes(menus: :menu_items)
    render json: @restaurants.as_json(include: { menus: { include: :menu_items } })
  end

  def show
    @restaurant = Restaurant.includes(menus: :menu_items).find(params[:id])
    render json: @restaurant.as_json(include: { menus: { include: :menu_items } })
  end
end
