# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :date_night_slot do
    available_on "2014-08-08"
    starting_at "2014-08-08 01:16:11"
    guaranteed_openings 1
  end
end
