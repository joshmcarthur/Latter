Latter::Application.routes.draw do
  devise_for :players

  resources :games, :except => [:edit, :update] do
    post :complete, :on => :member
  end

  resources :players

  root :to => 'players#index'
end
