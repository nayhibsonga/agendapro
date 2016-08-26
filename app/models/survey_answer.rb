class SurveyAnswer < ActiveRecord::Base
  belongs_to :booking
  belongs_to :survey_question
end
