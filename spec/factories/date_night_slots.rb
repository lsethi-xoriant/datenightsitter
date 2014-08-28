# == Schema Information
#
# Table name: date_night_slots
#
#  id                  :integer          not null, primary key
#  available_on        :date
#  starting_at         :time
#  guaranteed_openings :integer
#  created_at          :datetime
#  updated_at          :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :date_night_slot do
    available_on { Date.today + rand(1..60) }
    starting_at { Time.now + rand(0..100000) } 
    guaranteed_openings 1
  end
end
