require 'test_helper'

class PuntoPagosControllerTest < ActionController::TestCase
  test "should get generate_transaction" do
    get :generate_transaction
    assert_response :success
  end

  test "should get recive_results" do
    get :recive_results
    assert_response :success
  end

end
