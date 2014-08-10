# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sitting do
    type ""
    status "MyString"
    provider nil
    seeker nil
    started_at "2014-08-07 23:22:27"
    ended_at "2014-08-07 23:22:27"
  end
end
