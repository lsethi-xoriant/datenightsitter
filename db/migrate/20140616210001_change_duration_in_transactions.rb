class ChangeDurationInTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :duration, :decimal, precision: 10, scale: 4
  end
end
