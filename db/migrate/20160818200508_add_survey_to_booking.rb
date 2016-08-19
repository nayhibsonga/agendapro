class AddSurveyToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :survey, index: true
  end
end
