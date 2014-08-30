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

class DateNightSitting < Sitting
  belongs_to :date_night_slot

end