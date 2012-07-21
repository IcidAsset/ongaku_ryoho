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
  get 'settings' => 'pages#settings'
  get 'account' => 'pages#account'

  # sessions/users
  get 'logout' => 'sessions#destroy', :as => 'logout'
  get 'login' => 'sessions#new', :as => 'login'
  get 'signup' => 'users#new', :as => 'signup'

  resources :users
  resources :sessions

  # root
  root :to => 'default#index'

end
