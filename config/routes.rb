Latter::Application.routes.draw do
  devise_for :players

  resources :games, :except => [:edit, :update] do
    post :complete, :on => :member
    resource :score, :controller => 'scores', :only => [:new, :create]
  end

  resources :activities, :controller => 'activity', :only => :index
  resources :statistics, :only => [:index]
  resources :players
  resources :badges, :only => [:index]

  root :to => 'players#index'
  match "/pages/*slug" => "pages#show", :as => 'page'
end
