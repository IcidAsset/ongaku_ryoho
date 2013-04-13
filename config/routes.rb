OngakuRyoho::Application.routes.draw do

  # api
  namespace :data do
    resources :tracks, only: [:index]
    resources :favourites, only: [:index, :create, :destroy]
    resources :playlists, only: [:index, :create, :update, :destroy]

    resources :sources, only: [:index, :show] do
      member do
        get 'process', action: :process_source
        get 'check', action: :check_source
      end
    end
  end

  # TODO
  resources :servers, except: [:show]

  # pages
  get 'about' => 'pages#about'
  get 'settings' => 'pages#settings'
  get 'tools' => 'pages#tools'
  get 'faq' => 'pages#faq'

  # settings
  put 'settings' => 'pages#update_settings'

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
