Rails.application.routes.draw do
  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    root "dashboard#index"
    resources :products do
      resources :variants, only: [ :new, :create, :edit, :update, :destroy ],
                           controller: "product_variants"
    end
    resources :categories
    resources :faqs
    resources :reels
  end
end
