class AddDefaulToBookings < ActiveRecord::Migration
  def change
  	change_column :bookings, :notes, :text, default: ""
  	change_column :bookings, :company_comment, :text, default: ""
  end
end
