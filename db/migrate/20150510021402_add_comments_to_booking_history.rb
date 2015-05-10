class AddCommentsToBookingHistory < ActiveRecord::Migration
  def change
    add_column :booking_histories, :notes, :text, default: ""
    add_column :booking_histories, :company_comment, :text, default: ""
  end
end
