Rails.application.routes.draw do
  get 'pages/rules'
  get 'accesses/show'
  root to: "sites#index"
  get 'reservations/complete', to: 'reservations#complete', as: 'reservation_complete'
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