class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey_attribute
  belongs_to :company

  has_many :survey_question_constructs, dependent: :destroy
  has_many :survey_constructs, through: :survey_question_constructs

  has_many :survey_answers

  validates :question,presence: true, allow_blank: false

  private

  def name_with_initial
    return self.question.html_safe
  end
end
