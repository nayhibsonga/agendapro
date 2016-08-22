class AddBookingToSurveyAnswer < ActiveRecord::Migration
  def change
    add_reference :survey_answers, :booking, index: true
  end
end
