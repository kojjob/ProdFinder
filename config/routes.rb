Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    confirmations: "users/confirmations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  # Static pages
  get "community", to: "pages#community", as: :community
  get "pricing", to: "pages#pricing", as: :pricing
  get "maker_guide", to: "pages#maker_guide", as: :maker_guide

  # User resources
  resources :users, only: [ :show, :edit, :update ] do
    member do
      get :products
    end
  end

  # Product resources
  resources :products, only: [ :index, :show, :new, :create, :edit, :update ] do
    resources :comments, only: [ :create, :destroy ]
    resources :upvotes, only: [ :create, :destroy ]
  end

  # Category resources
  resources :categories, only: [ :index, :show ]

  # Topic resources
  resources :topics, only: [ :index, :show ]

  # Collection resources
  resources :collections, only: [ :index, :show, :new, :create, :edit, :update ]

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Settings
  get "settings", to: "settings#index", as: :settings
  patch "settings", to: "settings#update"

  # My Products
  get "my_products", to: "products#my_products", as: :my_products
end
