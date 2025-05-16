Rails.application.routes.draw do
  get 'accesses/show'
  root to: "sites#index"
  get 'sites/introduction', to: 'sites#show', as: 'site'
  get 'access', to: 'accesses#show'
  resources :sites, only: [:index, :show]
  resources :items, only: [:index]
  resources :reservations, only: [:new, :create, :index, :destroy]

  # ← 先に Devise を宣言
  devise_for :users

  # そのあとに users#show
  resources :users, only: [:show]
end