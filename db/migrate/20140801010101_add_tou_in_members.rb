class AddTouInMembers < ActiveRecord::Migration
  def change
    add_column :members, :accepted_tou_at, :datetime
  end
end
