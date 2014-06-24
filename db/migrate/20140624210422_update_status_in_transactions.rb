class UpdateStatusInTransactions < ActiveRecord::Migration

  def up
    execute "UPDATE transactions SET status = IF(payment_token IS NOT NULL, 'paid', 'requested');"
      
  end
  
  def down
    execute "UPDATE transactions SET status = NULL;"
    
  end
end
