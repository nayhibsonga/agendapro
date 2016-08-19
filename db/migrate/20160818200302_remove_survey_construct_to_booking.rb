class RemoveSurveyConstructToBooking < ActiveRecord::Migration
  def change
    remove_reference :bookings, :survey_construct, index: true
  end
end
