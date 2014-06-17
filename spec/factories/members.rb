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
    
    factory :provider, class: Provider do |p|
      p.first_name 'approve_me'
    end
    
    factory :provider_fail, class: Provider do |pf|
      pf.first_name '82626' 
    end

    factory :seeker, class: Seeker, parent: :member do |s|
      s.type "Seeker"
      s.date_of_birth nil
    end
    
  end
end
