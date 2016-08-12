class AddBookingToSurvey < ActiveRecord::Migration
  def change
    add_reference :surveys, :booking, index: true
  end
end
