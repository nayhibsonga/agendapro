class RemoveSurveyToBooking < ActiveRecord::Migration
  def change
    remove_reference :bookings, :survey, index: true
  end
end
