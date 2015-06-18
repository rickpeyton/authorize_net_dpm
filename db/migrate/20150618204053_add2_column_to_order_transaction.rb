class Add2ColumnToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :transaction, :string
  end
end
