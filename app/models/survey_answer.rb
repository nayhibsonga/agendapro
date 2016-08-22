class SurveyAnswer < ActiveRecord::Base
  belongs_to :booking
  has_many :questions
end
