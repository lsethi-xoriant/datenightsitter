class DateNightSlot < ActiveRecord::Base
  has_many :date_night_sittings, :dependent => :destroy

  #scope for checking
  scope :available_on_today_beyond, -> { where("available_on >=?", Date.today).order(:available_on => :asc) }

end