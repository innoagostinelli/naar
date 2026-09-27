Rails.application.routes.draw do
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :orders, only: [ :create ]
  get "buscar", to: "search#index", as: :search
  get "products/:id/gallery", to: "products#gallery", as: :product_gallery
  get "sitemap.xml", to: "sitemaps#show", as: :sitemap, defaults: { format: :xml }

  namespace :admin do
    get  "login",  to: "sessions#new",     as: :login
    post "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    resource :password, only: [ :edit, :update ], controller: "passwords"

    root "dashboard#index"
    resources :products do
      collection { get :deleted }
      member { patch :restore }
      resources :variants, only: [ :create, :update, :destroy ],
                           controller: "product_variants"
      resources :images, only: [ :new, :create, :edit, :update, :destroy ],
                         controller: "product_images"
    end
    resources :categories
    resources :faqs
    resources :reels
    resources :payment_methods do
      member { patch :toggle }
    end
    resources :orders, only: [ :index, :show, :update ]
    resource :homepage_setting, only: [ :edit, :update ]
    resource :banner_setting, only: [ :edit, :update ]
  end
end
