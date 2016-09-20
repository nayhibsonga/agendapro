class AddNoteToPettyTransaction < ActiveRecord::Migration
  def change
  	add_column :petty_transactions, :notes, :text
  end
end
