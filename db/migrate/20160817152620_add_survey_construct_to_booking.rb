class AddSurveyConstructToBooking < ActiveRecord::Migration
  def change
    add_reference :bookings, :survey_construct, index: true
  end
end
