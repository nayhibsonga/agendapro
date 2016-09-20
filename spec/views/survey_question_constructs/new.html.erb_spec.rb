require 'rails_helper'

RSpec.describe "survey_question_constructs/new", :type => :view do
  before(:each) do
    assign(:survey_question_construct, SurveyQuestionConstruct.new(
      :survey_question => nil,
      :survey_construct => nil
    ))
  end

  it "renders new survey_question_construct form" do
    render

    assert_select "form[action=?][method=?]", survey_question_constructs_path, "post" do

      assert_select "input#survey_question_construct_survey_question_id[name=?]", "survey_question_construct[survey_question_id]"

      assert_select "input#survey_question_construct_survey_construct_id[name=?]", "survey_question_construct[survey_construct_id]"
    end
  end
end
