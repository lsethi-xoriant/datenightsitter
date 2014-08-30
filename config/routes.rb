Rails.application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "members#new", :as => "sign_up"
  get 'account_check' => "accounts#account_check"
  root :to => "sessions#new"

  resources :date_night_sitting

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
      get :resend_request
    end
  end

  namespace :members, path: nil, as: nil do
    namespace :management, as: :admin do
      root to: "admins#index", as: "dashboard", path: "/dashboard"
      resources :date_night_slots, :except => :show
      resources :sittings, only: [:create, :update, :destroy] do
        collection do
          get :date_night_sittings
        end
        member do
          post :fire_status_event
        end
      end
    end
    namespace :parent, path: nil, as: nil do
      resources :seekers, path: 'parent' do
        get :dashboard
        get :profile
      end
    end
    namespace :sitter, path: nil, as: nil do
      resources :providers, path: 'sitter' do
        get :bank_account
        get :dashboard
        get :date_night_availability
        get :invite_parent
        get :invited
        get :settle_up
        get :profile
        get :terms_of_use
        post :update_date_night_availability
        post :add_bank_account
        post :add_seeker
        post :submit_bill
      end
    end
  end

end