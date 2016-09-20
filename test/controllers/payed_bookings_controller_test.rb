require 'test_helper'

class PayedBookingsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get get_by_user" do
    get :get_by_user
    assert_response :success
  end

end
