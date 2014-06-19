# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    type ""
    provider nil
    seeker nil
    sender "MyString"
    subject "MyString"
    body "MyText"
  end
end
