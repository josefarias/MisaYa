Rails.application.routes.draw do
  resources :states, only: [] do
    resources :municipalities, only: %i[index show]
  end

  resources :sessions, only: %i[new create]

  root "sessions#new"
end
