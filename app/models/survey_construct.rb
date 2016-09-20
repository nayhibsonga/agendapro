class SurveyConstruct < ActiveRecord::Base

  belongs_to :booking

  has_many :service_survey_constructs, dependent: :destroy
  has_many :services, through: :service_survey_constructs

  has_many :survey_question_constructs, dependent: :destroy
  has_many :survey_questions, through: :survey_question_constructs

end
