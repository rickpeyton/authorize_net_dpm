class RanameTransactionColumnName < ActiveRecord::Migration
  def change
    rename_column(:order_transactions, :transaction, :transaction_number)
  end
end
