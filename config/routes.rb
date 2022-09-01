Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :trips, shallow: true do
    resources :bookings, only: %i[new create destroy update edit show]
    resources :hotels, only: %i[update edit]
    resources :flights, only: %i[update edit]
  end
end
