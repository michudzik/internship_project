Rails.application.routes.draw do
  root 'home#home'
  devise_for :users
  get '/new_ticket', to: 'tickets#new'
  get '/show_tickets', to: 'tickets#index'
  get '/user_dashboard', to: 'users#show'
  resources :users, only: [:index, :update] do
    resources :comments, only: :create
    resources :tickets
    member do
      put :deactivate_account
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
