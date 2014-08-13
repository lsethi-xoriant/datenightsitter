class DateNightSlot < ActiveRecord::Base
  has_many :date_night_sittings, :dependent => :destroy
  
end
