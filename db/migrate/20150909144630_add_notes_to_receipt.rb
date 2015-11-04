class AddNotesToReceipt < ActiveRecord::Migration
  def change
  	add_column :receipts, :notes, :text, default: ""
  end
end
