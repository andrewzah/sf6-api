require 'sidekiq/web'

Rails.application.routes.draw do
  root 'public#index'

  namespace :api do
    namespace :v1 do
      resources :jobs, only: [:create]
    end
  end

  mount Sidekiq::Web => '/sidekiq'
end

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
