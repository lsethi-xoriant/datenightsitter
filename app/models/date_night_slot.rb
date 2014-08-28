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

class DateNightSlot < ActiveRecord::Base
  has_many :date_night_sittings, :dependent => :destroy
  
  include GeneralFilter::GenFilter

  #scope for checking
  scope :available_on_today_beyond, -> { where("available_on >=?", Date.today).order(:available_on => :asc) }

end
