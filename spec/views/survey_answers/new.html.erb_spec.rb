require 'rails_helper'

RSpec.describe "survey_answers/new", :type => :view do
  before(:each) do
    assign(:survey_answer, SurveyAnswer.new())
  end

  it "renders new survey_answer form" do
    render

    assert_select "form[action=?][method=?]", survey_answers_path, "post" do
    end
  end
end
