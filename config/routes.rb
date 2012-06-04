Latter::Application.routes.draw do
  devise_for :players

  resources :games, :except => [:edit, :update] do
    post :complete, :on => :member
  end

  resources :players
end
