class CreateSittingStatusTransitions < ActiveRecord::Migration
  def change
    create_table :sitting_status_transitions do |t|
      t.references :sitting, index: true
      t.string :event
      t.string :from
      t.string :to
      t.string :calling_member_id, :integer
      t.timestamp :created_at
    end
  end
end
