class AddActivateI18nToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :activate_i18n, :boolean, default: false
  end
end
