class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey_construct
  belongs_to :survey_attribute
  has_many :survey_answers
end
