class AddUuidInMembers < ActiveRecord::Migration
  def change
    add_column :members, :sso_uuid, :string
  end
end
