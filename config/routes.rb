Rails.application.routes.draw do

  get 'home/index'

  get 'password_resets/new'

  get 'log_out' => 'sessions#destroy', as: 'log_out'
  get 'log_in' => 'sessions#new', as: 'log_in'
  get 'sign_up' => 'users#new', as: 'sign_up'
  root to: 'home#index'

  resources :users
  resources :sessions
  resources :password_resets
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
