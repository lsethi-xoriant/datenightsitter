class UpdateTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :status, :string, :limit => 15
  end
end
