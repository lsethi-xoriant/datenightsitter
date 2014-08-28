# == Schema Information
#
# Table name: sittings
#
#  id                 :integer          not null, primary key
#  type               :string(255)
#  status             :string(255)
#  provider_id        :integer
#  seeker_id          :integer
#  started_at         :datetime
#  ended_at           :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  date_night_slot_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sitting do
    type ""
    provider nil
    seeker nil
    started_at "2014-08-07 23:22:27"
    ended_at "2014-08-07 23:22:27"
  end
  
  factory :sitting_available, :parent => :sitting do |sa|
    sa.status "available"
  end
  
  factory :sitting_unavailable, :parent => :sitting do |su|
    su.status "unavailable"
  end
end
