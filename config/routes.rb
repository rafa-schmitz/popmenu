Rails.application.routes.draw do
  # API routes for Level 3
  namespace :api do
    resources :restaurants, only: [ :index, :show ]
    resources :menus, only: [ :index, :show ]
    resources :menu_items, only: [ :index ]
    resources :imports, only: [ :create ]
  end
end
