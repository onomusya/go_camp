Rails.application.routes.draw do
  root to: "sites#index"
  resources :sites, only: [:index]
  devise_for :users
end
