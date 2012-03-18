OngakuRyoho::Application.routes.draw do
  resources :default, :only => [:index]
  resources :sources, :only => [:index]
  resources :tracks,  :only => [:index]

  resources :servers, :except => [:index]
  resources :buckets, :except => [:index]

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  resources :users
  resources :sessions

  root :to => 'default#index'
end
