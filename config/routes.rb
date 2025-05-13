Rails.application.routes.draw do
  root to: "sites#index"
  resources :sites, only: [:index]
  resources :reservations, only: [:new, :create, :index, :destroy]
  devise_for :users
end
