# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    first_name "MyString"
    last_name "MyString"
    address "MyString"
    city "MyString"
    state "MyString"
    zip "MyString"
    email "MyString"
    phone "MyString"
  end
end
