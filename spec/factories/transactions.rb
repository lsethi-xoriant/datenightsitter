# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction, :class => 'Transactions' do
    type ""
    status "MyString"
    amount ""
    merchant_account nil
    payment_account nil
    processor_transaction_id "MyString"
  end
end
