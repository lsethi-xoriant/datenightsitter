# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :date_night_sitting do
    type "DateNightSitting"
    provider nil
    seeker nil
    started_at "2014-08-07 23:22:27"
    ended_at "2014-08-07 23:22:27"
  end
  
  factory :date_night_sitting_available, :parent => :date_night_sitting do |sa|
    sa.status "available"
    sa.provider  { FactoryGirl.create(:provider)}
  end
  
  factory :date_night_sitting_unavailable, :parent => :date_night_sitting do |su|
    su.status "unavailable"
    su.provider  { FactoryGirl.create(:provider)}
  end
end
