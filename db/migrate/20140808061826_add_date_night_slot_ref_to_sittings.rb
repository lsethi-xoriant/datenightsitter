class AddDateNightSlotRefToSittings < ActiveRecord::Migration
  def change
    add_reference :sittings, :date_night_slot, index: true
  end
end
