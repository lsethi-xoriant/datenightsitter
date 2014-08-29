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

  #scope - default filter for Date Night Slots - Greater or equal than today's date
  scope :def_sort, -> (def_sort = 'available_on desc') { order(def_sort) }
  scope :def_filter, -> { where("available_on >=?", Date.today).order(:available_on => :asc) }

  def self.def_paginate(page = 1)
    self.def_sort.paginate(:page => page, :per_page => 5)
  end

end