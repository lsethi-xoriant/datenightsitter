class ChangeTimeFormatInDateNightSlots < ActiveRecord::Migration
  def change
    change_column :date_night_slots, :starting_at, :time
  end
end
