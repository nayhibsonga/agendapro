class AddNotesToInternalSale < ActiveRecord::Migration
  def change
    add_column :internal_sales, :notes, :text, default: ""
  end
end
