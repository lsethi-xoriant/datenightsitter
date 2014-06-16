class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :seeker, index:true
      t.references :provider, index:true
      t.string :merchant_account_id
      t.string :payment_token
      t.integer :status
      t.money :amount
      t.money :rate
      t.datetime :started_at
      t.decimal :duration
      t.money :service_fee_amount
      t.string :processor_transaction_id

      t.index :merchant_account_id
      t.index :payment_token

      t.timestamps
    end
  end
end
