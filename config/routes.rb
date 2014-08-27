Rails.application.routes.draw do

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "members#new", :as => "sign_up"
  get 'account_check' => "accounts#account_check"
  root :to => "sessions#new"

=begin
  resources :members do
    member do
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
=end

  scope module: 'members' do
    namespace :admin do
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
    scope module: 'seeker' do
      resources :seekers do
        get :dashboard, as: 'dashboard_seeker'
      end
    end
    scope module: 'provider' do
      resources :providers do
        get :bank_account
        get :dashboard, as: 'dashboard_provider'
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

end
