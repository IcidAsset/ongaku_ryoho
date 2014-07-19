OngakuRyoho::Application.routes.draw do

  # api
  namespace :api do
    resources :tracks,      only: [:index]
    resources :favourites,  only: [:index, :create, :destroy]
    resources :playlists,   only: [:index, :create, :update, :destroy]

    resources :sources,     only: [:index, :show, :create, :update, :destroy] do
      member do
        get :file_list
        post :update_tracks
        get :s3_signed_url
        get :dropbox_media_url
      end

      collection do
        get :dropbox_authorize_url
      end
    end
  end

  # pages
  get 'about'       => 'pages#about'
  get 'settings'    => 'pages#settings'
  get 'tools'       => 'pages#tools'
  get 'faq'         => 'pages#faq'

  # settings
  put 'settings'    => 'pages#update_settings'

  # sessions/users
  devise_for :users, skip: [:sessions, :registrations]
  as :user do
    get     'sign-in'  => 'sessions#new',     as: 'new_user_session'
    post    'sign-in'  => 'sessions#create',  as: 'user_session'
    get     'sign-out' => 'sessions#destroy', as: 'destroy_user_session'

    # registrations
    get   'sign-up' => 'users#new',    as: 'new_user_registration'
    post  'sign-up' => 'users#create', as: 'user_registration'

    # account
    get 'account' => 'users#edit',   as: 'edit_user_registration'
    put 'account' => 'users#update', as: 'update_user_registration'

    # account deletion
    delete 'account' => 'users#destroy'

    # account created page
    get 'account-created'   => 'users#account_created'
  end

  # root
  root :to => 'default#index'

end
