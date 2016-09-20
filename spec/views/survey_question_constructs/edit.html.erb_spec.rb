require 'rails_helper'

RSpec.describe "survey_question_constructs/edit", :type => :view do
  before(:each) do
    @survey_question_construct = assign(:survey_question_construct, SurveyQuestionConstruct.create!(
      :survey_question => nil,
      :survey_construct => nil
    ))
  end

  it "renders the edit survey_question_construct form" do
    render

    assert_select "form[action=?][method=?]", survey_question_construct_path(@survey_question_construct), "post" do

      assert_select "input#survey_question_construct_survey_question_id[name=?]", "survey_question_construct[survey_question_id]"

      assert_select "input#survey_question_construct_survey_construct_id[name=?]", "survey_question_construct[survey_construct_id]"
    end
  end
end
