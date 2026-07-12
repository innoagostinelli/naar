Rails.application.routes.draw do
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :orders, only: [ :create ]

  namespace :admin do
    root "dashboard#index"
    resources :products do
      resources :variants, only: [ :new, :create, :edit, :update, :destroy ],
                           controller: "product_variants"
      resources :images, only: [ :new, :create, :edit, :update, :destroy ],
                         controller: "product_images"
    end
    resources :categories
    resources :faqs
    resources :reels
    resources :orders, only: [ :index, :show, :update ]
    resource :homepage_setting, only: [ :edit, :update ]
  end
end
