class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :type
      t.string :email
      t.string :phone
      t.string :password_hash
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.date :date_of_birth
      t.string :merchant_account_id
      t.string :payment_account_id

      t.timestamps
      
      t.index :email, unique:true
      t.index :phone, unique:true
      t.index :merchant_account_id, unique:true
      t.index :payment_account_id, unique:true
    end
  end
end
