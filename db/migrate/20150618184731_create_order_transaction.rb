class CreateOrderTransaction < ActiveRecord::Migration
  def change
    create_table :order_transactions do |t|
      t.string :action
      t.decimal :amount
      t.boolean :success
      t.string :authorization
      t.text :params
    end
  end
end
