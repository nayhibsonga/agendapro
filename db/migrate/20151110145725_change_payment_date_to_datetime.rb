class ChangePaymentDateToDatetime < ActiveRecord::Migration
  def change
  	change_column :payments, :payment_date, :datetime, default: DateTime.now
  end
end
