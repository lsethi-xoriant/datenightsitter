# Read about factories at https://github.com/thoughtbot/factory_girl
require "faker"

FactoryGirl.define do
  factory :member do
    type "Provider"
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip { Faker::Address.zip }
    email { Faker::Internet.email }
    phone {"(312) 555-#{rand(1000..9999)}"}
    password { Faker::Internet.password(8) }
    date_of_birth { Date.new(1978, 5, 23) }
  end
  
  factory :provider, :parent => :member, :class => Provider do |p|
    p.first_name 'approve_me'
    p.phone "6174708045"
    p.accepted_tou_at { Date.today }
  end
  
  factory :provider_fail, :parent => :member, :class => Provider do |p|
    p.first_name '82626' 
    p.phone "6174708045"
  end
    
  factory :provider_with_merchant_account, :parent => :member, :class => Provider do |p|
    p.merchant_account_id "approve_me_conrad_instant_k6njfjxy"
    p.phone "6174708045"
  end

  factory :seeker, class: Seeker, :parent => :member do |s|
    s.type "Seeker"
    last_name { Faker::Name.last_name }
    s.accepted_tou_at { Date.today }
  end
  
  factory :seeker_for_comm, class: Seeker, :parent => :seeker do |s|
    s.type "Seeker"
    s.phone "3129700557"
    s.email "andrewconrad.shop@gmail.com"
  end
  factory :seeker_with_payment_account, :parent => :member, :class => Seeker do |s|
    s.type "Seeker"
    s.payment_account_id "40886601"
    s.phone "3129700557"
    s.email "andrewconrad.shop@gmail.com"
  end
    
  factory :seeker_trans_update, :class => Seeker do |s|
    s.zip  { Faker::Address.zip }
    s.email "andrewconrad.shop@gmail.com"
  end
  
  factory :seeker_base_attr, :class => Seeker do |s|
    email { Faker::Internet.email }
    phone {"(312) 555-#{rand(1000..9999)}"}
    last_name { Faker::Name.last_name }
  end

  factory :admin, :parent => :member, :class => Admin do |p|
  end
  
end
