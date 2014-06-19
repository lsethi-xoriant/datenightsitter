Rails.application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "members#new", :as => "sign_up"
  root :to => "sessions#new"
  
  resources :members do
    member do
      get :bank_account
      get :dashboard
      get :provider_dashboard
      get :seeker_dashboard
      get :settle_up
      post :add_bank_account
      post :submit_bill
    end
  end
  
  resources :sessions
  
  resources :transactions do
    member do
      get :review
      put :update
    end
  end
  
  resources :settle_up, controller:"transactions" do
    member do
      get :review
      put :update
    end
  end

end
