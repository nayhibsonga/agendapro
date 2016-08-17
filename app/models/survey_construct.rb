class SurveyConstruct < ActiveRecord::Base
  belongs_to :booking

  has_many :service_survey_constructs, dependent: :destroy
  has_many :services, through: :service_survey_constructs

  has_many :survey_questions, dependent: :destroy, :inverse_of => :survey_construct

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  accepts_nested_attributes_for :survey_questions, :allow_destroy => true

  WORKER = 'SurveyConstructEmailWorker'
end
