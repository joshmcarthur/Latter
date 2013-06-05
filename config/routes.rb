Latter::Application.routes.draw do
  devise_for :players

  scope :constraints => {:protocol => (Rails.env.production? ? 'https://' : 'http://')} do
    namespace :api do
      namespace :v1 do
        resources :players, :only => :index
        resources :games, :only => :index
      end
    end
  end

  resources :games, :except => [:edit, :update] do
    post :complete, :on => :member
    resource :score, :controller => 'scores', :only => [:new, :create]
  end

  resources :activities, :controller => 'activity', :only => :index
  resources :statistics, :only => [:index]
  resources :players
  resources :badges, :only => [:index, :show]

  root :to => 'players#index'
  match "/pages/*slug" => "pages#show", :as => 'page'

end
