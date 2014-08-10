class CreateDateNightSlots < ActiveRecord::Migration
  def change
    create_table :date_night_slots do |t|
      t.date :available_on
      t.datetime :starting_at
      t.integer :guaranteed_openings

      t.timestamps
    end
  end
end
