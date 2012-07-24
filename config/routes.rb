OngakuRyoho::Application.routes.draw do

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
  get 'tools' => 'pages#tools'

  # sessions/users
  get 'sign-up' => 'users#new', :as => 'sign_up'
  get 'sign-in' => 'sessions#new', :as => 'sign_in'
  get 'sign-out' => 'sessions#destroy', :as => 'sign_out'

  post 'sign-in' => 'sessions#create'
  post 'sign-up' => 'users#create'

  get 'account' => 'users#edit', :as => 'account'
  put 'account' => 'users#update'

  # root
  root :to => 'default#index'

end
