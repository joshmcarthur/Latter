Latter::Application.routes.draw do
  devise_for :players

  resources :games
end
