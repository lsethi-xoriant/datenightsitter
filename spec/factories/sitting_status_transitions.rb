# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sitting_status_transition do
    sitter nil
    event "MyString"
    from "MyString"
    to "MyString"
    created_at "2014-08-08 00:28:16"
  end
end
