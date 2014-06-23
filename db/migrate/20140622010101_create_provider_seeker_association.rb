class CreateProviderSeekerAssociation < ActiveRecord::Migration
  def change
    create_table :members_members do |t|
      t.belongs_to :provider
      t.belongs_to :seeker
    end
      
    execute "INSERT INTO members_members (provider_id, seeker_id) SELECT distinct provider_id, seeker_id FROM transactions;"
      
  end
  
end