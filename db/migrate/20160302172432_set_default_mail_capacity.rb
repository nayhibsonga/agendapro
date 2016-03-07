class SetDefaultMailCapacity < ActiveRecord::Migration
  def change
  	change_column_default(:company_settings, :mails_base_capacity, 5000)
  end
end
