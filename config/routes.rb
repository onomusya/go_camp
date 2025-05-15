Rails.application.routes.draw do
  root to: "sites#index"
  get 'sites/introduction', to: 'sites#show', as: 'site'
  resources :sites, only: [:index, :show]
  resources :items, only: [:index]
  resources :reservations, only: [:new, :create, :index, :destroy]

  # ← 先に Devise を宣言
  devise_for :users

  # そのあとに users#show
  resources :users, only: [:show]
end