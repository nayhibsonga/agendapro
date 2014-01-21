require 'test_helper'

class MandrillControllerTest < ActionController::TestCase
  test "should get unsuscribe" do
    get :unsuscribe
    assert_response :success
  end

  test "should get resuscribe" do
    get :resuscribe
    assert_response :success
  end

end
