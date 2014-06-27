Rails.application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "members#new", :as => "sign_up"
  root :to => "sessions#new"
  
  resources :members do
    member do
      get :autocomplete_search_connections_by_phone
      get :autocomplete_search_connections_by_last_name
      get :bank_account
      get :dashboard
      get :invite_parent
      get :settle_up
      get :profile
      post :add_bank_account
      post :add_seeker
      post :submit_bill
    end
  end
  
  resources :sessions do
    collection do
      get :forgot_password
      post :verify_member
      post :change_password
    end
  end
  
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
