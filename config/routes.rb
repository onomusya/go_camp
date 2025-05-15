Rails.application.routes.draw do
  root to: "sites#index"
  resources :sites, only: [:index]
  resources :items, only: [:index]
  resources :reservations, only: [:new, :create, :index, :destroy]

  # ← 先に Devise を宣言
  devise_for :users

  # そのあとに users#show
  resources :users, only: [:show]
end