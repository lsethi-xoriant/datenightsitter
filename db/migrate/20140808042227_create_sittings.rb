class CreateSittings < ActiveRecord::Migration
  def change
    create_table :sittings do |t|
      t.string :type
      t.string :status
      t.references :provider, index: true
      t.references :seeker, index: true
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
