class AddTaxToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :sales_tax, :float, default: 0.0, null: false
  end
end
