# Read about factories at https://github.com/thoughtbot/factory_girl
require "faker"

FactoryGirl.define do
  factory :transaction do
    status "started"
  end
  
  
  factory :trans_requested, :class => Transaction, :parent => :transaction do |t|
    t.seeker { FactoryGirl.create(:seeker_with_payment_account)}
    t.provider { FactoryGirl.create(:provider_with_merchant_account)}
    t.merchant_account_id { Provider.last.merchant_account_id }
    t.started_at { DateTime.now }
    t.duration { rand(8) }
    t.rate { rand(25) }
    t.status "requested"
  end
  
  
  factory :trans_pay_params, :class => Transaction do
    amount { 35 + rand(50) + rand.round(2) }
  end
  
  factory :trans_request_params, :class => Transaction do
    started_at "Wed Jun 25 2014 02:00:00 GMT-0500 (CDT)"
    duration { 1 + rand(8) }
    rate { rand(25) }
  end
end
