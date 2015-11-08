require 'sidekiq/web'
Rails.application.routes.draw do


  get 'auth/:provider/callback' => 'sessions#create'
  get '/signout' => 'sessions#destroy', :as => :signout

  resources :dashboard
  resources :members
  resources :about


  root 'site#index'
  mount Sidekiq::Web, at: "/sidekiq"
end
