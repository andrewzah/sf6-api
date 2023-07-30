Rails.application.routes.draw do
  root 'public#index'
  namespace :api do
    namespace :v1 do
      resources :jobs, only: [:create]
    end
  end
end

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html