class AddLocalesToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :locale, :string, default: ""
    add_column :countries, :flag_photo, :string, default: ""
  end
end
