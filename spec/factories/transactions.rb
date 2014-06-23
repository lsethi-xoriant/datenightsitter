# Read about factories at https://github.com/thoughtbot/factory_girl
require "faker"

FactoryGirl.define do
  factory :transaction do
    
  end
  
  factory :trans_awaiting_completion, :class => Transaction do |t|
    t.seeker { FactoryGirl.create(:seeker_with_payment_account)}
    t.provider { FactoryGirl.create(:provider_with_merchant_account)}
    t.merchant_account_id { Provider.last.merchant_account_id }
    t.started_at { DateTime.now }
    t.duration { rand(8) }
    t.rate { rand(25) }
  end
  
  factory :trans_initiate, :class => Transaction do
    started_at { DateTime.now }
    duration { rand(8) }
    rate { rand(25) }
  end
    
  factory :trans_update, :class => Transaction do
    amount { 35 + rand(50) + rand.round(2) }
  end
end
