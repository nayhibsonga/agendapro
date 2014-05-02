class AddCompanyCommentToBooking < ActiveRecord::Migration
  def change
  	add_column :bookings, :company_comment, :text
  end
end
