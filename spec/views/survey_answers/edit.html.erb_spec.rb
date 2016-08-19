require 'rails_helper'

RSpec.describe "survey_answers/edit", :type => :view do
  before(:each) do
    @survey_answer = assign(:survey_answer, SurveyAnswer.create!())
  end

  it "renders the edit survey_answer form" do
    render

    assert_select "form[action=?][method=?]", survey_answer_path(@survey_answer), "post" do
    end
  end
end
