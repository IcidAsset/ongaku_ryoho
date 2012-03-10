OngakuRyoho::Application.routes.draw do
  resources :default, :only => [:index]
  resources :sources, :only => [:index]
  resources :tracks,  :only => [:index]
  
  resources :servers, :except => [:index]
  
  root :to => 'default#index'
end
