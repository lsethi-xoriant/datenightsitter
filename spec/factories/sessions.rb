# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  
  factory :creds, class:Hash do
    email "sittercity_qa_20140810@sittercity.com"
    password "sittercity"
    
  end

end