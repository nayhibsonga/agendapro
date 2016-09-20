class ServiceSurveyConstruct < ActiveRecord::Base
  belongs_to :service
  belongs_to :survey_construct

  validates :service,presence: true, allow_blank: false
end
