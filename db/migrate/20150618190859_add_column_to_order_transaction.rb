class AddColumnToOrderTransaction < ActiveRecord::Migration
  def change
    add_column :order_transactions, :message, :string
  end
end
