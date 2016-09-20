class AddCurrencyCodeToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :currency_code, :string, default: ""
  end
end
