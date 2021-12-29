Rails.application.routes.draw do
  resources :states, only: [] do
    member do
      resources :municipalities, only: :index
    end
  end

  root "sessions#new"
end
