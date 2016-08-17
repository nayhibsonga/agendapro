class SurveyConstruct < ActiveRecord::Base
  has_many :survey_questions, dependent: :destroy, :inverse_of => :survey_construct
  belongs_to :booking

  has_many :service_survey_constructs, dependent: :destroy
  has_many :services, through: :service_survey_constructs
  accepts_nested_attributes_for :survey_questions, :allow_destroy => true
end
