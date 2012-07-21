OngakuRyoho::Application.routes.draw do

  resources :default, :only => [:index]

  # api
  resources :tracks, :only => [:index]
  resources :favourites, :only => [:index, :create, :destroy]

  resources :sources, :only => [:index] do
    member do
      get 'process', :action => :process_source
      get 'check', :action => :check_source
    end
  end

  resources :servers

  # pages
  get 'about' => 'pages#about'
  get 'settings' => 'pages#settings'
  get 'account' => 'pages#account'
  get 'tools' => 'pages#tools'

  # sessions/users
  get 'sign-up' => 'users#new', :as => 'sign_up'
  get 'sign-in' => 'sessions#new', :as => 'sign_in'
  get 'sign-out' => 'sessions#destroy', :as => 'sign_out'

  resources :users, :only => [:create]
  resources :sessions, :only => [:create]

  # root
  root :to => 'default#index'

end
